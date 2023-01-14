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

using namespace std;
using namespace ARDUINOJSON_NAMESPACE;

const char* KEY_VERSION = "version";
const char* KEY_WIFI_MODE = "wifi_mode";
const char* KEY_SSID = "ssid";
const char* KEY_PASSWORD = "password";
const char* KEY_REFRESH_RATE_LEVEL = "refresh_rate_level";
const char* KEY_SERIAL_BAUD_RATE = "serial_baud_rate";

SnakeEyeSettings Settings;

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
  StaticJsonDocument<128> json;
  deserializeJson(json, stream);
  if (version_ != json[KEY_VERSION]) return;
  wifi_mode_ = static_cast<WifiMode>(json[KEY_WIFI_MODE].as<uint8_t>());
  strncpy(ssid_, json[KEY_SSID].as<const char*>(), MAX_SSID_LENGTH);
  strncpy(password_, json[KEY_PASSWORD].as<const char*>(), MAX_PASSWORD_LENGTH);
  refresh_rate_level_ = json[KEY_REFRESH_RATE_LEVEL];
  serial_baud_rate_ = json[KEY_SERIAL_BAUD_RATE];
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