/**
 * Copyright (C) 2020-2023 Jason C.H.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "settings.hpp"

#include <EEPROM.h>
#include <MLX90640_API.h>

using namespace std;
using namespace ArduinoJson;

const char* KEY_VERSION = "version";
const char* KEY_WIFI_MODE = "wifi_mode";
const char* KEY_SSID = "ssid";
const char* KEY_PASSWORD = "password";
const char* KEY_REFRESH_RATE_LEVEL = "refresh_rate_level";
const char* KEY_SERIAL_BAUD_RATE = "serial_baud_rate";

SnakeEyeSettings Settings;

void SnakeEyeSettings::set_refresh_rate_level(uint8_t level) {
  refresh_rate_level_ = level;
  MLX90640_SetRefreshRate(MLX90640_I2C_ADDR, level);
}

void SnakeEyeSettings::set_serial_baud_rate(uint32_t baud_rate) {
  serial_baud_rate_ = baud_rate;
  Serial.begin(baud_rate);
}

void SnakeEyeSettings::Load() {
  EEPROM.begin(sizeof(Settings));
  EEPROM.get(0, Settings);
  EEPROM.end();
}

void SnakeEyeSettings::Save() {
  EEPROM.begin(sizeof(Settings));
  EEPROM.put(0, Settings);
  EEPROM.end();
}

void SnakeEyeSettings::LoadFrom(Stream& stream) {
  StaticJsonDocument<192> json;
  deserializeJson(json, stream);
  if (version_ != json[KEY_VERSION]) return;

  auto need_restart = false;

  auto wifi_mode = static_cast<WifiMode>(json[KEY_WIFI_MODE].as<uint8_t>());
  if (wifi_mode != wifi_mode_) {
    wifi_mode_ = wifi_mode;
    need_restart = true;
  }

  auto ssid = json[KEY_SSID].as<const char*>();
  if (strcmp(ssid, ssid_) != 0) {
    strncpy(ssid_, ssid, MAX_SSID_LENGTH);
    need_restart = true;
  }

  auto password = json[KEY_PASSWORD].as<const char*>();
  if (strcmp(password, password_) != 0) {
    strncpy(password_, password, MAX_PASSWORD_LENGTH);
    need_restart = true;
  }

  auto refresh_rate_level = json[KEY_REFRESH_RATE_LEVEL].as<uint8_t>();
  if (refresh_rate_level != refresh_rate_level_) {
    set_refresh_rate_level(refresh_rate_level);
  }

  auto serial_baud_rate = json[KEY_SERIAL_BAUD_RATE].as<uint32_t>();
  if (serial_baud_rate != serial_baud_rate_) {
    set_serial_baud_rate(serial_baud_rate);
  }

  Save();
  if (need_restart) ESP.restart();
}

size_t SnakeEyeSettings::writeTo(Stream& stream) {
  auto json = toJson();
  return serializeJson(json, stream);
}

size_t SnakeEyeSettings::writeTo(char* buffer, size_t buffer_size) {
  auto json = toJson();
  return serializeJson(json, buffer, buffer_size);
}

StaticJsonDocument<128> SnakeEyeSettings::toJson() {
  StaticJsonDocument<128> json;
  json[KEY_VERSION] = version_;
  json[KEY_WIFI_MODE] = static_cast<uint8_t>(wifi_mode_);
  json[KEY_SSID] = ssid_;
  json[KEY_PASSWORD] = password_;
  json[KEY_REFRESH_RATE_LEVEL] = refresh_rate_level_;
  json[KEY_SERIAL_BAUD_RATE] = serial_baud_rate_;
  return json;
}
