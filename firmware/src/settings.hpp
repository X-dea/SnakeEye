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

#pragma once

#include <ArduinoJson.hpp>
#include <cstdint>

#include "config.h"

enum class WifiMode : uint8_t {
  kAP,
  kSTA,
};

class SnakeEyeSettings {
 public:
  uint32_t version_ = VERSION;
  WifiMode wifi_mode_ = WifiMode::kAP;
  char ssid_[MAX_SSID_LENGTH] = DEFAULT_SSID;
  char password_[MAX_PASSWORD_LENGTH] = DEFAULT_PASSWORD;
  uint8_t refresh_rate_level_ = 0x03;
  uint32_t serial_baud_rate_ = 230400;

  /**
   * @brief Set and apply the refresh rate level.
   *
   * @param level The refresh rate level.
   */
  void set_refresh_rate_level(uint8_t level);

  /**
   * @brief Set and apply the serial baud rate.
   *
   * @param baud_rate The serial baud rate.
   */
  void set_serial_baud_rate(uint32_t baud_rate);

  /**
   * @brief Load settings from EEPROM.
   */
  void Load();

  /**
   * @brief Save settings to EEPROM.
   */
  void Save();

  /**
   * @brief Load settings from stream in JSON format.
   *
   * @param stream Source stream.
   */
  void LoadFrom(Stream& stream);

  /**
   * @brief Write settings to stream in JSON format.
   *
   * @param stream Destination stream.
   * @return size_t Number of bytes written.
   */
  size_t writeTo(Stream& stream);

  /**
   * @brief Write settings to buffer in JSON format.
   *
   * @param buffer Destination buffer.
   * @param buffer_size Size of destination buffer.
   * @return size_t Number of bytes written.
   */
  size_t writeTo(char* buffer, size_t buffer_size);

 private:
  ArduinoJson::StaticJsonDocument<128> toJson();
};

extern SnakeEyeSettings Settings;
