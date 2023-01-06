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
  uint8_t refresh_rate_level_ = 0x03;
  uint32_t serial_baud_rate_ = 460800;

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

class SnakeEyeState {
 public:
  bool udp_client_attached_ = false;
  bool serial_client_attached_ = false;
  inline bool DebugPrint() { return !serial_client_attached_; }
};

extern SnakeEyeState State;