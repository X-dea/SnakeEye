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

int MLX90640_I2CGeneralReset(void) { return 0; }

int MLX90640_I2CRead(uint8_t slaveAddr, uint16_t startAddress,
                     uint16_t nMemAddressRead, uint16_t *data) {
  uint16_t remaining_bytes = nMemAddressRead * 2;
  uint16_t read_bytes = 0;

  // Chunked read
  while (remaining_bytes > 0) {
    Wire.beginTransmission(slaveAddr);
    Wire.write(startAddress >> 8);
    Wire.write(startAddress & 0xFF);
    if (Wire.endTransmission(false) != 0) {
      return -1;
    }

    uint16_t chunked_bytes =
        remaining_bytes > BUFFER_LENGTH ? BUFFER_LENGTH : remaining_bytes;

    Wire.requestFrom(slaveAddr, chunked_bytes);
    if (Wire.available()) {
      for (uint16_t i = 0; i < chunked_bytes / 2; i++, read_bytes++) {
        data[read_bytes] = Wire.read() << 8;
        data[read_bytes] |= Wire.read();
      }
    }

    remaining_bytes -= chunked_bytes;
    startAddress += chunked_bytes / 2;
  }

  return 0;
}

void MLX90640_I2CFreqSet(int freq) { Wire.setClock(1000U * freq); }

int MLX90640_I2CWrite(uint8_t slaveAddr, uint16_t writeAddress, uint16_t data) {
  // Write
  Wire.beginTransmission(slaveAddr);
  Wire.write(writeAddress >> 8);
  Wire.write(writeAddress & 0xFF);
  Wire.write(data >> 8);
  Wire.write(data & 0xFF);
  if (Wire.endTransmission() != 0) return -1;

  // Check
  uint16_t actual = 0;
  MLX90640_I2CRead(slaveAddr, writeAddress, 1, &actual);
  if (actual != data) return -2;

  return 0;
}
