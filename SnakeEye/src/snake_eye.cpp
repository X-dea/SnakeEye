
#include <Arduino.h>
#include <MLX90640_API.h>
#include <MLX90640_I2C_Driver.h>

#define MLX90640_I2C_ADDR 0x33

paramsMLX90640 mlx90640_params;

void setup() {
  Serial.begin(115200);

  MLX90640_I2CInit();
  MLX90640_I2CFreqSet(400);

  uint16_t mlx90640_eeprom[832];
  if (MLX90640_DumpEE(MLX90640_I2C_ADDR, mlx90640_eeprom) != 0) {
    Serial.println("Failed to dump eeprom of MLX90640.");
  }

  if (MLX90640_ExtractParameters(mlx90640_eeprom, &mlx90640_params) != 0) {
    Serial.println("Failed to extract params of MLX90640.");
  }

  MLX90640_SetRefreshRate(MLX90640_I2C_ADDR, 0x05);
  MLX90640_I2CFreqSet(800);
}
