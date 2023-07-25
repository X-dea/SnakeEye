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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ulink/ulink.dart';
import 'package:usb_serial/usb_serial.dart';

import 'connection.dart';
import 'main_page.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final _addressController = TextEditingController(
    text: 'udp://192.168.4.1:55544',
  );

  void _serial() async {
    final deviceId = await showDialog<int>(
      context: context,
      builder: (context) => const _SerialPortSelection(),
    );
    if (deviceId != null) {
      _addressController.text = 'serial://$deviceId?baud_rate=230400';
    }
  }

  void _connect() async {
    final addr = _addressController.text;
    try {
      final uri = Uri.parse(addr);
      final Connection connection;
      switch (uri.scheme) {
        case 'udp':
          connection = Connection(
            channel: UdpChannel(uri),
          );
          break;
        case 'serial':
          connection = Connection(
            channel: SerialChannel(
              uri,
              splitter: TerminatorSplitter(
                terminator: [0xF0, 0xF1],
              ),
            ),
          );
          break;
        default:
          throw const FormatException();
      }

      connection.connect();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MainPage(connection: connection),
        ),
      );
      connection.disconnect();
    } on FormatException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid address.')),
        );
      }
    } on ArgumentError catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid address.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to SnakeEye'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Address',
                  ),
                ),
              ),
              if (Platform.isAndroid)
                ListTile(
                  title: const Text('Serial Port'),
                  onTap: _serial,
                ),
              const SizedBox(height: 8),
              FloatingActionButton(
                onPressed: _connect,
                child: const Icon(Icons.link),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SerialPortSelection extends StatefulWidget {
  const _SerialPortSelection();

  @override
  State<_SerialPortSelection> createState() => _SerialPortSelectionState();
}

class _SerialPortSelectionState extends State<_SerialPortSelection> {
  List<UsbDevice>? _usbDevices;

  Future<void> _refreshUsbDevices() async {
    _usbDevices = await UsbSerial.listDevices();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    _refreshUsbDevices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final usbDevices = _usbDevices;

    if (usbDevices == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SimpleDialog(
      title: const Text('Serial Port'),
      clipBehavior: Clip.hardEdge,
      children: [
        for (final device in usbDevices)
          ListTile(
            title: Text(device.deviceName),
            onTap: () => Navigator.of(context).pop(device.deviceId),
          ),
      ],
    );
  }
}
