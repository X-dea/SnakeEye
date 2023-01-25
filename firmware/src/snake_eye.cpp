#include <Arduino.h>
#include <ArduinoOTA.h>
#include <ESP8266WiFi.h>
#include <MLX90640_API.h>
#include <MLX90640_I2C_Driver.h>
#include <WiFiUdp.h>

#include "config.h"
#include "settings.hpp"
#include "state.hpp"

static const uint8_t terminator[] = {0xF0, 0xF1};

static paramsMLX90640 mlx90640_params;
static uint16_t mlx90640_frame[834];
static float mlx90640_temperature[768];

static WiFiUDP udp;

bool FetchFrame() {
  if (MLX90640_GetFrameData(MLX90640_I2C_ADDR, mlx90640_frame) < 0) {
    if (State.DebugPrint()) {
      Serial.println(F("MLX90640: Failed to get frame."));
    }
    return false;
  }

  MLX90640_CalculateTo(mlx90640_frame, &mlx90640_params, 0.95,
                       MLX90640_GetTa(mlx90640_frame, &mlx90640_params) - 8,
                       mlx90640_temperature);

  MLX90640_BadPixelsCorrection(mlx90640_params.brokenPixels,
                               mlx90640_temperature, 1, &mlx90640_params);

  return true;
}

void setup() {
  Settings.Load();
  if (Settings.version_ != VERSION) {
    Settings = SnakeEyeSettings();
    Settings.Save();
  }

  Serial.begin(Settings.serial_baud_rate_);

  Serial.printf("Setup WiFi: %s %s\n", Settings.ssid_, Settings.password_);
  if (Settings.wifi_mode_ == WifiMode::kAP) {
    WiFi.softAP(Settings.ssid_, Settings.password_);
  } else {
    WiFi.begin(Settings.ssid_, Settings.password_);
  }

  MLX90640_I2CInit();
  MLX90640_I2CFreqSet(400);

  uint16_t mlx90640_eeprom[832];
  if (MLX90640_DumpEE(MLX90640_I2C_ADDR, mlx90640_eeprom) != 0) {
    Serial.println(F("MLX90640: Failed to dump EEPROM."));
    ESP.restart();
  }

  int ret = MLX90640_ExtractParameters(mlx90640_eeprom, &mlx90640_params);
  switch (ret) {
    case 0:
      Serial.println(F("MLX90640: Initialized."));
      break;
    case -4:
      Serial.println(F("MLX90640: Too many outliers."));
      break;
    default:
      Serial.println(F("MLX90640: Failed to extract params."));
      ESP.restart();
  }

  MLX90640_SetRefreshRate(MLX90640_I2C_ADDR, Settings.refresh_rate_level_);
  MLX90640_I2CFreqSet(600);

  if (Settings.wifi_mode_ == WifiMode::kSTA) {
    if (WiFi.waitForConnectResult() != WL_CONNECTED) {
      Serial.println(F("Failed to connect WiFi."));
      ESP.restart();
    }

    Serial.print(F("WiFi connected. IP address: "));
    Serial.println(WiFi.localIP());
  }

  udp.begin(UDP_PORT);
  ArduinoOTA.begin(false);
}

void loop() {
  static IPAddress remote_ip;
  static uint16_t remote_port;

  if (udp.parsePacket()) {
    auto cmd = udp.read();
    switch (cmd) {
      case CMD_STOP_FRAMES:
        State.udp_client_attached_ = false;
        if (State.DebugPrint()) Serial.println(F("UDP client detached."));
        break;

      case CMD_START_FRAMES:
        remote_ip = udp.remoteIP();
        remote_port = udp.remotePort();
        State.udp_client_attached_ = true;
        if (State.DebugPrint()) {
          Serial.print(F("UDP client attached. IP address: "));
          Serial.println(remote_ip);
        }
        break;

      case CMD_GET_SETTINGS:
        udp.beginPacket(udp.remoteIP(), udp.remotePort());
        Settings.writeTo(udp);
        udp.endPacket();
        break;

      case CMD_SET_SETTINGS:
        Settings.LoadFrom(udp);
        break;

      default:
        break;
    }
  }

  if (Serial.available() > 0) {
    State.serial_client_detected_ = true;
    auto cmd = Serial.read();

    switch (cmd) {
      case CMD_STOP_FRAMES:
        State.serial_client_attached_ = false;
        break;

      case CMD_START_FRAMES:
        State.serial_client_attached_ = true;
        break;

      case CMD_GET_SETTINGS:
        Settings.writeTo(Serial);
        Serial.write(terminator, 2);
        break;

      default:
        break;
    }

    Serial.flush();
  }

  if (State.udp_client_attached_ || State.serial_client_attached_) {
    if (!FetchFrame()) return;

    if (State.udp_client_attached_) {
      udp.beginPacket(remote_ip, remote_port);
      udp.write((uint8_t*)mlx90640_temperature, 768 * 4);
      if (udp.endPacket()) {
        delay(10);  // Prevent IP fragment loss.
      } else {
        State.udp_client_attached_ = false;
      }
    }

    if (State.serial_client_attached_) {
      if (!Serial.write((uint8_t*)mlx90640_temperature, 768 * 4) ||
          !Serial.write(terminator, 2)) {
        State.serial_client_attached_ = false;
      }
    }
  }

  ArduinoOTA.handle();
}
