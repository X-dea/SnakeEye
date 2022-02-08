#pragma once

#include <ESP8266WebServer.h>

class WebController {
 private:
  bool Validate();
  void ChangeToAPMode();
  void ChangeToSTAMode();
  void SetRate();

 public:
  ESP8266WebServer server_;

  void Setup();
};

extern WebController Web;