#include "web.hpp"

#include "settings.hpp"

WebController Web;

bool WebController::Validate() {
  if (!server_.hasArg("ssid") || !server_.hasArg("password") ||
      server_.arg("ssid").length() >= MAX_SSID_LENGTH ||
      server_.arg("password").length() >= MAX_PASSWORD_LENGTH) {
    server_.send(400);
    return false;
  }

  return true;
}

void WebController::ChangeToAPMode() {
  if (!Validate()) return;

  auto ssid = server_.arg("ssid").c_str();
  auto password = server_.arg("password").c_str();

  Serial.printf("Changing to AP mode: %s %s\n", ssid, password);

  strcpy(Settings.ssid_, ssid);
  strcpy(Settings.password_, password);

  Settings.mode_ = Mode::kAP;
  Settings.Save();

  server_.send(200);
  ESP.restart();
}

void WebController::ChangeToSTAMode() {
  if (!Validate()) return;

  auto ssid = server_.arg("ssid").c_str();
  auto password = server_.arg("password").c_str();

  Serial.printf("Changing to STA mode: %s %s\n", ssid, password);

  strcpy(Settings.ssid_, ssid);
  strcpy(Settings.password_, password);

  Settings.mode_ = Mode::kSTA;
  Settings.Save();

  server_.send(200);
  ESP.restart();
}

void WebController::Setup() {
  server_.begin();
  server_.on("/ap", [this]() { ChangeToAPMode(); });
  server_.on("/sta", [this]() { ChangeToSTAMode(); });
}