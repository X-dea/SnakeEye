
#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <MLX90640_API.h>
#include <MLX90640_I2C_Driver.h>
#include <WiFiUdp.h>

#include "config.h"
#include "settings.hpp"
#include "web.hpp"

paramsMLX90640 mlx90640_params;
WiFiUDP udp;

bool SendFrame(IPAddress& address) {
  static float mlx90640_temperature[768];
  static uint16_t mlx90640_frame[834];

  if (MLX90640_GetFrameData(MLX90640_I2C_ADDR, mlx90640_frame) < 0) {
    Serial.println("Failed to get frame from MLX90640.");
    return true;
  }

  MLX90640_CalculateTo(mlx90640_frame, &mlx90640_params, 0.95,
                       MLX90640_GetTa(mlx90640_frame, &mlx90640_params) - 8,
                       mlx90640_temperature);

  MLX90640_BadPixelsCorrection(mlx90640_params.brokenPixels,
                               mlx90640_temperature, 1, &mlx90640_params);

  udp.beginPacket(address, UDP_PORT);
  udp.write((uint8_t*)mlx90640_temperature, 768 * 4);
  return udp.endPacket();
}

void setup() {
  Serial.begin(115200);

  Settings.Load();
  if (Settings.version_ != VERSION) {
    Settings = SnakeEyeSettings();
    Settings.Save();
  }

  Serial.printf("Setup WiFi: %s %s\n", Settings.ssid_, Settings.password_);
  if (Settings.mode_ == Mode::kAP) {
    WiFi.softAP(Settings.ssid_, Settings.password_);
  } else {
    WiFi.begin(Settings.ssid_, Settings.password_);
  }

  MLX90640_I2CInit();
  MLX90640_I2CFreqSet(400);

  uint16_t mlx90640_eeprom[832];
  if (MLX90640_DumpEE(MLX90640_I2C_ADDR, mlx90640_eeprom) != 0) {
    Serial.println(F("Failed to dump eeprom of MLX90640."));
    exit(1);
  }

  if (MLX90640_ExtractParameters(mlx90640_eeprom, &mlx90640_params) != 0) {
    Serial.println(F("Failed to extract params of MLX90640."));
    exit(1);
  }

  MLX90640_SetRefreshRate(MLX90640_I2C_ADDR, Settings.refresh_rate_level_);
  MLX90640_I2CFreqSet(600);

  if (Settings.mode_ == Mode::kSTA) {
    if (WiFi.waitForConnectResult() != WL_CONNECTED) {
      Serial.println(F("Failed to connect WiFi."));
      exit(1);
    }

    Serial.print(F("WiFi connected. IP address: "));
    Serial.println(WiFi.localIP());
  }

  udp.begin(UDP_PORT);
  Web.Setup();
}

void loop() {
  static IPAddress remote_ip;
  static auto client_attached = false;

  if (udp.parsePacket()) {
    auto r = udp.read();
    if (r == 0x0) {
      client_attached = false;
      Serial.println(F("Client detached."));
    } else {
      remote_ip = udp.remoteIP();
      client_attached = true;
      Serial.print(F("Client attached. IP address: "));
      Serial.println(remote_ip);
    }
  }

  if (client_attached) {
    if (SendFrame(remote_ip)) {
      delay(10);  // Prevent IP fragment loss.
    } else {
      client_attached = false;
    }
  }

  Web.server_.handleClient();
}