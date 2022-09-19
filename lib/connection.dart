// Copyright (C) 2020-2022 Jason C.H.

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
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

import 'common.dart';

abstract class Connection {
  /// Start receiving frame data.
  Stream<Float32List> receiveFrames();

  /// Stop receiving frame data.
  Future<void> stopFrames();
}

/// A connection to SnakeEye via UDP.
class UdpConnection implements Connection {
  final InternetAddress address;
  final int port;

  RawDatagramSocket? socket;

  factory UdpConnection(Uri uri) {
    assert(uri.scheme == 'udp');
    return UdpConnection._(InternetAddress(uri.host), uri.port);
  }

  UdpConnection._(this.address, this.port);

  @override
  Stream<Float32List> receiveFrames() async* {
    final s = socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      55544,
    );

    s.send([0x1], address, port);

    await for (var p in s) {
      if (p != RawSocketEvent.read) continue;
      final dg = s.receive();
      if (dg == null || dg.data.lengthInBytes != rawFrameLength) continue;
      yield dg.data.buffer.asFloat32List();
    }
  }

  @override
  Future<void> stopFrames() async {
    socket?.send([0x0], address, port);
    socket?.close();
  }
}

mixin ConnectionProcessor<T extends StatefulWidget> on State<T> {
  var temps = Float32List(sensorWidth * sensorHeight);
  RawDatagramSocket? socket;
  UsbPort? port;

  String get address;

  void processTemperatures(Float32List temps);

  void refreshUdp() async {
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 55544);
    final s = socket;
    if (s == null) return;

    s.send([0x1], InternetAddress(address), 55544);
    await for (var p in s) {
      if (p != RawSocketEvent.read) continue;
      final dg = s.receive();
      if (dg == null || dg.data.lengthInBytes != sensorPixels * 4) continue;
      temps = dg.data.buffer.asFloat32List();
      processTemperatures(temps);
    }
  }

  void refreshSerial() async {
    final uri = Uri.tryParse(address);
    if (uri == null || uri.scheme != 'serial') return;

    final deviceId = int.tryParse(uri.host);
    if (deviceId == null) return;

    port = await UsbSerial.createFromDeviceId(deviceId);
    final p = port;
    if (p == null) return;

    await p.open();
    await p.setDTR(true);
    await p.setRTS(true);
    await p.setPortParameters(
      int.parse(uri.queryParameters['baud_rate'] ?? '460800'),
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );

    final transaction = Transaction.terminated(
      p.inputStream!,
      Uint8List.fromList([0xF0, 0xF1]),
    );

    p.write(Uint8List.fromList([1]));
    await for (var p in transaction.stream) {
      if (p.lengthInBytes != sensorPixels * 4) return;
      temps = p.buffer.asFloat32List();
      processTemperatures(temps);
    }
  }

  @override
  void initState() {
    if (address.startsWith('serial://')) {
      refreshSerial();
    } else {
      refreshUdp();
    }
    super.initState();
  }

  @override
  void dispose() {
    socket?.send([0x0], InternetAddress(address), 55544);
    socket?.close();
    port?.write(Uint8List.fromList([0x0])).then((_) {
      port?.close();
    });
    super.dispose();
  }
}
