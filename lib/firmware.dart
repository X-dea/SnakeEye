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

import 'connection/connection.dart';
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
  SnakeEyeSettings? _settings;

  Future<void> _load() async {
    _settings = await widget.connection.settings;
    if (mounted) setState(() {});
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
      title: const Text('Settings'),
      contentPadding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: const Text('Version'),
          trailing: Text(
            '${settings.version ~/ 10000}.${settings.version % 10000 ~/ 100}.${settings.version % 100}',
          ),
        ),
      ],
    );
  }
}
