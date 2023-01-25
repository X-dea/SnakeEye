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
import 'dart:typed_data';

import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

import '../common.dart';
import '../setting.dart';
import 'connection.dart';

/// A connection to SnakeEye via serial port.
class SerialConnection implements Connection {
  final int deviceId;
  final int baudRate;

  UsbPort? _port;
  Stream<Uint8List>? _stream;

  factory SerialConnection(Uri uri) {
    assert(uri.scheme == 'serial');
    return SerialConnection._(
      int.parse(uri.host),
      int.parse(uri.queryParameters['baud_rate'] ?? '460800'),
    );
  }

  SerialConnection._(this.deviceId, this.baudRate);

  @override
  Future<void> connect() async {
    final p = _port = await UsbSerial.createFromDeviceId(deviceId);
    if (p == null) return;

    await p.open();
    await p.setDTR(true);
    await p.setRTS(true);
    await p.setPortParameters(
      baudRate,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );

    _stream = Transaction.terminated(
      p.inputStream!,
      Uint8List.fromList([0xF0, 0xF1]),
    ).stream.asBroadcastStream();
  }

  @override
  Future<void> disconnect() async {
    await _port?.close();
    _port = null;
    _stream = null;
  }

  @override
  Stream<Float32List> receiveFrames() async* {
    final stream = _stream;
    if (stream == null) {
      throw StateError('disconnected');
    }

    _port?.write(Uint8List.fromList([Command.startFrames.index]));

    await for (var p in stream) {
      if (p.lengthInBytes != rawFrameLength) return;
      yield p.buffer.asFloat32List();
    }
  }

  @override
  Future<void> stopFrames() async {
    await _port?.write(Uint8List.fromList([Command.stopFrames.index]));
  }

  @override
  Future<SnakeEyeSettings?> get settings async {
    _port?.write(Uint8List.fromList([Command.getSettings.index]));
    return _stream?.first.then((data) {
      if (data.first == 123 && data.last == 125) {
        try {
          final json = jsonDecode(utf8.decode(data));
          return SnakeEyeSettings.fromJson(json);
        } catch (_) {
          return null;
        }
      } else {
        return null;
      }
    });
  }

  @override
  Future<void> saveSettings(SnakeEyeSettings settings) {
    throw UnimplementedError();
  }
}
