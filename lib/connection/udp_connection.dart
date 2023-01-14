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
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../common.dart';
import '../setting.dart';
import 'connection.dart';

/// A connection to SnakeEye via UDP.
class UdpConnection implements Connection {
  final InternetAddress address;
  final int port;

  RawDatagramSocket? _socket;
  Stream<Uint8List>? _stream;

  factory UdpConnection(Uri uri) {
    assert(uri.scheme == 'udp');
    return UdpConnection._(InternetAddress(uri.host), uri.port);
  }

  UdpConnection._(this.address, this.port);

  @override
  Future<void> connect() async {
    final s = _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      55544,
    );

    _stream = s
        .where((event) => event == RawSocketEvent.read)
        .map((event) => s.receive()!.data)
        .asBroadcastStream();
  }

  @override
  Future<void> disconnect() async {
    _socket?.close();
    _socket = null;
    _stream = null;
  }

  @override
  Stream<Float32List> receiveFrames() async* {
    final stream = _stream;
    if (stream == null) {
      throw StateError('disconnected');
    }

    _socket?.send([0x1], address, port);

    await for (var data in stream) {
      if (data.lengthInBytes != rawFrameLength) continue;
      yield data.buffer.asFloat32List();
    }
  }

  @override
  Future<void> stopFrames() async {
    _socket?.send([0x0], address, port);
  }

  @override
  Future<SnakeEyeSettings?> get settings {
    final completer = Completer<SnakeEyeSettings?>();
    _stream?.first.then((data) {
      if (data.first == 123 && data.last == 125) {
        try {
          final json = jsonDecode(utf8.decode(data));
          completer.complete(SnakeEyeSettings.fromJson(json));
        } catch (_) {
          completer.complete(null);
        }
      } else {
        completer.complete(null);
      }
    });
    _socket?.send([0x2], address, port);
    return completer.future;
  }

  @override
  Future<void> saveSettings(SnakeEyeSettings settings) {
    throw UnimplementedError();
  }
}
