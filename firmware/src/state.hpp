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

class SnakeEyeState {
 public:
  bool udp_client_attached_ = false;
  bool serial_client_attached_ = false;
  bool serial_client_detected_ = false;
  inline bool DebugPrint() { return !serial_client_detected_; }
};

extern SnakeEyeState State;
