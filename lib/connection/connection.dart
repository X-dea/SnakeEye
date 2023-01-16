// Copyright (C) 2020-2023 Jason C.H.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';
import 'dart:typed_data';

import '../setting.dart';

enum Command {
  stopFrames,
  startFrames,
  getSettings,
  saveSettings,
}

/// Represent a connection to device.
abstract class Connection {
  /// Establish connection to device.
  Future<void> connect();

  /// Disconnect from device.
  Future<void> disconnect();

  /// Start receiving frame data.
  Stream<Float32List> receiveFrames();

  /// Stop receiving frame data.
  Future<void> stopFrames();

  /// Obtain settings from device.
  Future<SnakeEyeSettings?> get settings;

  /// Save settings to device.
  Future<void> saveSettings(SnakeEyeSettings settings);
}