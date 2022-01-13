#pragma once

#include <ESP8266WebServer.h>

class WebController {
 public:
  ESP8266WebServer server_;

  void Setup();

 private:
  bool Validate();
  void ChangeToAPMode();
  void ChangeToSTAMode();
};

extern WebController Web;