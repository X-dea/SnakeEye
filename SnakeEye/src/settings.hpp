#pragma once

#include <Arduino.h>

#include "config.h"

enum class Mode : uint8_t {
  kAP,
  kSTA,
};

class SnakeEyeSettings {
 public:
  uint32_t version_ = VERSION;
  Mode mode_ = Mode::kAP;

  char ssid_[MAX_SSID_LENGTH] = DEFAULT_SSID;
  char password_[MAX_PASSWORD_LENGTH] = DEFAULT_PASSWORD;

  /**
   * @brief Load settings from EEPROM.
   */
  void Load();

  /**
   * @brief Save settings to EEPROM.
   */
  void Save();
};

extern SnakeEyeSettings Settings;