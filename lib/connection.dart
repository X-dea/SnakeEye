import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

import 'common.dart';

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
      if (dg == null || dg.data.lengthInBytes != sensorResolution * 4) continue;
      temps = dg.data.buffer.asFloat32List();
      processTemperatures(temps);
    }
  }

  void refreshSerial() async {
    final deviceId = int.tryParse(address.split('//').last);
    if (deviceId == null) return;

    port = await UsbSerial.createFromDeviceId(deviceId);
    final p = port;
    if (p == null) return;

    await p.open();
    await p.setDTR(true);
    await p.setRTS(true);
    await p.setPortParameters(
      115200,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );

    final transaction = Transaction.terminated(
      p.inputStream!,
      Uint8List.fromList([0xFF, 0x00, 0xFF, 0x00]),
    );

    p.write(Uint8List.fromList([1]));
    await for (var p in transaction.stream) {
      if (p.lengthInBytes != sensorResolution * 4) return;
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
