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

import 'package:espota/espota.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'connection/connection.dart';
import 'connection/udp_connection.dart';
import 'setting.dart';

class FirmwareDialog extends StatefulWidget {
  final Connection connection;

  const FirmwareDialog({super.key, required this.connection});

  static Future<void> show(BuildContext context, Connection connection) async {
    await showDialog(
      context: context,
      builder: (context) => FirmwareDialog(connection: connection),
    );
  }

  @override
  State<FirmwareDialog> createState() => _FirmwareDialogState();
}

class _FirmwareDialogState extends State<FirmwareDialog> {
  static const bundledVersion = 10000;
  SnakeEyeSettings? _settings;
  double? _progress;

  Future<void> _load() async {
    _settings = await widget.connection.settings;
    if (mounted) setState(() {});
  }

  Future<void> flash() async {
    final address = (widget.connection as UdpConnection).address;
    final fw = await rootBundle.load('res/firmware.bin');
    if (mounted) setState(() => _progress = 0);

    try {
      await for (final progress
          in await upgrade(address, fw.buffer.asUint8List())) {
        if (mounted) setState(() => _progress = progress);
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Done'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    }
  }

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SimpleDialog(
      title: const Text('Firmware'),
      contentPadding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: const Text('Current Version'),
          trailing: Text(
            '${settings.version ~/ 10000}.${settings.version % 10000 ~/ 100}.${settings.version % 100}',
          ),
        ),
        if (widget.connection is UdpConnection)
          ListTile(
            title: const Text('Bundled Version'),
            subtitle: const Text('Tap to flash.'),
            trailing: _progress != null
                ? CircularProgressIndicator(value: _progress)
                : const Text(
                    '${bundledVersion ~/ 10000}.${bundledVersion % 10000 ~/ 100}.${bundledVersion % 100}',
                  ),
            onTap: flash,
          ),
      ],
    );
  }
}
