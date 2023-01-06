/**
 * @copyright (C) 2017 Melexis N.V.
 * @copyright (C) 2021 Jason C.H.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
#include "MLX90640_I2C_Driver.h"

#include <Wire.h>

void MLX90640_I2CInit() { Wire.begin(); }

int MLX90640_I2CGeneralReset() { return 0; }

void MLX90640_I2CFreqSet(int freq) { Wire.setClock(1000U * freq); }

int MLX90640_I2CRead(uint8_t slave_addr, uint16_t start_addr,
                     uint16_t num_of_addr, uint16_t *data) {
  uint16_t remaining_bytes = num_of_addr * 2;
  uint16_t read_bytes = 0;

  // Chunked read
  while (remaining_bytes > 0) {
    Wire.beginTransmission(slave_addr);
    Wire.write(start_addr >> 8);
    Wire.write(start_addr & 0xFF);
    if (Wire.endTransmission(false) != 0) {
      return -1;
    }

    uint8_t chunked_bytes =
        remaining_bytes > BUFFER_LENGTH ? BUFFER_LENGTH : remaining_bytes;

    Wire.requestFrom(slave_addr, chunked_bytes);
    if (Wire.available()) {
      for (uint16_t i = 0; i < chunked_bytes / 2; i++, read_bytes++) {
        data[read_bytes] = Wire.read() << 8;
        data[read_bytes] |= Wire.read();
      }
    }

    remaining_bytes -= chunked_bytes;
    start_addr += chunked_bytes / 2;
  }

  return 0;
}

int MLX90640_I2CWrite(uint8_t slave_addr, uint16_t write_addr, uint16_t data) {
  // Write
  Wire.beginTransmission(slave_addr);
  Wire.write(write_addr >> 8);
  Wire.write(write_addr & 0xFF);
  Wire.write(data >> 8);
  Wire.write(data & 0xFF);
  if (Wire.endTransmission() != 0) return -1;

  // Check
  uint16_t actual = 0;
  MLX90640_I2CRead(slave_addr, write_addr, 1, &actual);
  if (actual != data) return -2;

  return 0;
}
