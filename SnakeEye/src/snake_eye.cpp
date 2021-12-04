
#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <MLX90640_API.h>
#include <MLX90640_I2C_Driver.h>
#include <WiFiUdp.h>

#include "config.h"

paramsMLX90640 mlx90640_params;
WiFiUDP udp;

bool SendFrame(IPAddress& address) {
  static float mlx90640_temperature[768];

  for (uint8_t i = 0; i < 2; i++) {
    static uint16_t mlx90640_frame[834];
    if (MLX90640_GetFrameData(MLX90640_I2C_ADDR, mlx90640_frame) < 0) {
      Serial.println("Failed to get frame from MLX90640.");
      return true;
    }
    float Ta = MLX90640_GetTa(mlx90640_frame, &mlx90640_params);
    MLX90640_CalculateTo(mlx90640_frame, &mlx90640_params, 0.95, Ta - 8,
                         mlx90640_temperature);
  }

  MLX90640_BadPixelsCorrection(mlx90640_params.brokenPixels,
                               mlx90640_temperature, 1, &mlx90640_params);

  udp.beginPacket(address, UDP_PORT);
  udp.write((uint8_t*)mlx90640_temperature, 768 * 4);
  return udp.endPacket();
}

void setup() {
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  MLX90640_I2CInit();
  MLX90640_I2CFreqSet(400);

  uint16_t mlx90640_eeprom[832];
  if (MLX90640_DumpEE(MLX90640_I2C_ADDR, mlx90640_eeprom) != 0) {
    Serial.println("Failed to dump eeprom of MLX90640.");
    exit(1);
  }

  if (MLX90640_ExtractParameters(mlx90640_eeprom, &mlx90640_params) != 0) {
    Serial.println("Failed to extract params of MLX90640.");
    exit(1);
  }

  MLX90640_SetRefreshRate(MLX90640_I2C_ADDR, 0x05);
  MLX90640_I2CFreqSet(600);

  if (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.println("Failed to connect WiFi.");
    exit(1);
  }

  Serial.print("WiFi connected. IP address: ");
  Serial.println(WiFi.localIP());

  udp.begin(UDP_PORT);
}

void loop() {
  static IPAddress remote_ip;
  static auto client_attached = false;

  if (udp.parsePacket()) {
    auto r = udp.read();
    if (r == 0x0) {
      client_attached = false;
      Serial.print("Client detached.");
    } else {
      remote_ip = udp.remoteIP();
      client_attached = true;
      Serial.print("Client attached. IP address: ");
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
}