/**
 * @copyright (C) 2017 Melexis N.V.
 * @copyright (C) 2021-2023 Jason C.H.
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
#pragma once

#include <stdint.h>

void MLX90640_I2CInit(int sda, int scl);
int MLX90640_I2CGeneralReset();
void MLX90640_I2CFreqSet(int freq);
int MLX90640_I2CRead(uint8_t slave_addr, uint16_t start_addr,
                     uint16_t num_of_addr, uint16_t *data);
int MLX90640_I2CWrite(uint8_t slave_addr, uint16_t write_addr, uint16_t data);
