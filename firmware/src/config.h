/**
 * Copyright (C) 2020-2023 Jason C.H.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#pragma once

#define VERSION 1'00'00U

#define MLX90640_I2C_ADDR 0x33
#define UDP_PORT 55544

#define MAX_SSID_LENGTH 32
#define MAX_PASSWORD_LENGTH 32

#define DEFAULT_SSID "SnakeEye"
#define DEFAULT_PASSWORD "5nakeEye"

#define CMD_STOP_FRAMES 0
#define CMD_START_FRAMES 1
#define CMD_GET_SETTINGS 2
#define CMD_SET_SETTINGS 3
