
#include <Arduino.h>
#include <ESP8266WebServer.h>
#include <ESP8266WiFi.h>
#include <MLX90640_API.h>
#include <MLX90640_I2C_Driver.h>

#include "config.h"

paramsMLX90640 mlx90640_params;
ESP8266WebServer web_server;

void HandleRequest() {
  static float mlx90640_temperature[768];

  for (uint8_t i = 0; i < 2; i++) {
    static uint16_t mlx90640_frame[834];
    if (MLX90640_GetFrameData(MLX90640_I2C_ADDR, mlx90640_frame) < 0) {
      Serial.println("Failed to get frame from MLX90640.");
      exit(1);
    }
    float Ta = MLX90640_GetTa(mlx90640_frame, &mlx90640_params);
    MLX90640_CalculateTo(mlx90640_frame, &mlx90640_params, 0.95, Ta - 8,
                         mlx90640_temperature);
  }

  MLX90640_BadPixelsCorrection(mlx90640_params.brokenPixels,
                               mlx90640_temperature, 1, &mlx90640_params);

  web_server.send(200, "application/octet-stream", (char*)mlx90640_temperature,
                  768 * 4);
}

void setup() {
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  MLX90640_I2CInit();
  MLX90640_I2CFreqSet(400);

  uint16_t mlx90640_eeprom[832];
  if (MLX90640_DumpEE(MLX90640_I2C_ADDR, mlx90640_eeprom) != 0) {
    Serial.println("Failed to dump eeprom of MLX90640.");
    exit(1);
  }

  if (MLX90640_ExtractParameters(mlx90640_eeprom, &mlx90640_params) != 0) {
    Serial.println("Failed to extract params of MLX90640.");
    exit(1);
  }

  MLX90640_SetRefreshRate(MLX90640_I2C_ADDR, 0x05);
  MLX90640_I2CFreqSet(600);

  if (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.println("Failed to connect WiFi.");
    exit(1);
  }

  Serial.print("WiFi connected. IP address: ");
  Serial.println(WiFi.localIP());

  web_server.on("/", HandleRequest);
  web_server.begin();
}

void loop() { web_server.handleClient(); }