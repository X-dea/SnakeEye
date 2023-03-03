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

  var _usbDevices = <UsbDevice>[];

  Future<void> refreshUsbDevices() async {
    _usbDevices = await UsbSerial.listDevices();
    if (mounted) setState(() {});
  }

  void _connect() async {
    final addr = _addressController.text;
    try {
      final uri = Uri.parse(addr);
      final Connection connection;
      switch (uri.scheme) {
        case 'udp':
          connection = Connection(channel: UdpChannel(uri));
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

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainPage(connection: connection),
        ),
      );
    } on FormatException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid address.')),
      );
    } on ArgumentError catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid address.')),
      );
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
              ListTile(
                title: const Text('Serial Ports'),
                subtitle: const Text('Tap to refresh.'),
                trailing: DropdownButton<int>(
                  items: [
                    for (final d in _usbDevices)
                      DropdownMenuItem(
                        value: d.deviceId,
                        child: Text(d.deviceName),
                      ),
                  ],
                  onChanged: (v) =>
                      _addressController.text = 'serial://$v?baud_rate=230400',
                ),
                onTap: refreshUsbDevices,
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
