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

import 'dart:typed_data';

import 'package:ulink/ulink.dart';

import 'setting.dart';

enum Command {
  stopFrames,
  startFrames,
  getSettings,
  saveSettings,
}

/// Represent a connection to device.
class Connection {
  final BinaryCodec<TypedMessage> codec;
  final BinaryChannel channel;

  const Connection({
    required this.channel,
    this.codec = const JSONTypedMessageBinaryCodec(),
  });

  /// Establish connection to device.
  Future<void> connect() async {
    await channel.open();
  }

  /// Disconnect from device.
  Future<void> disconnect() async {
    await channel.close();
  }

  /// Start receiving frames.
  Stream<Float32List> receiveFrames() async* {
    await channel.send(
      codec.encode(
        TypedMessage(Command.startFrames.index, null),
      ),
    );
    yield* channel
        .receive()
        .where((e) => e.first == Command.startFrames.index)
        .map((e) => e.sublist(1))
        .map((m) => m.buffer.asFloat32List());
  }

  /// Stop receiving frames.
  Future<void> stopFrames() async {
    await channel.send(
      codec.encode(
        TypedMessage(Command.stopFrames.index, null),
      ),
    );
  }

  /// Get settings from device.
  Future<SnakeEyeSettings?> get settings async {
    channel.send(
      codec.encode(
        TypedMessage(Command.getSettings.index, null),
      ),
    );
    return channel
        .receive()
        .firstWhere((e) => e.first == Command.getSettings.index)
        .then((data) => SnakeEyeSettings.fromJson(codec.decode(data).message));
  }

  /// Save settings to device.
  Future<void> saveSettings(SnakeEyeSettings settings) async {
    await channel.send(
      codec.encode(
        TypedMessage(Command.saveSettings.index, settings),
      ),
    );
  }
}
