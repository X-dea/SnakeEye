#include "settings.hpp"

#include <EEPROM.h>

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

SnakeEyeState State;