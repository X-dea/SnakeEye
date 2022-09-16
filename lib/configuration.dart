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

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class WifiConfigurationDialog extends StatefulWidget {
  final String address;

  const WifiConfigurationDialog({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<WifiConfigurationDialog> createState() =>
      _WifiConfigurationDialogState();
}

class _WifiConfigurationDialogState extends State<WifiConfigurationDialog> {
  final formKey = GlobalKey<FormState>();
  var mode = 'ap';
  var ssidController = TextEditingController(text: 'SnakeEye');
  var passwordController = TextEditingController(text: '5nakeEye');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Wifi Configuration'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Mode'),
              trailing: DropdownButton<String>(
                value: mode,
                items: const [
                  DropdownMenuItem(
                    value: 'ap',
                    child: Text('AP'),
                  ),
                  DropdownMenuItem(
                    value: 'sta',
                    child: Text('STA'),
                  ),
                ],
                onChanged: (v) => setState(() => mode = v!),
              ),
            ),
            TextFormField(
              maxLength: 20,
              controller: ssidController,
              decoration: const InputDecoration(labelText: 'SSID'),
              validator: (v) => v == null || v.isEmpty || v.length >= 20
                  ? 'Invalid SSID'
                  : null,
            ),
            TextFormField(
              maxLength: 20,
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (v) => v == null || v.length < 8 || v.length >= 20
                  ? 'Invalid password'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Apply'),
          onPressed: () async {
            if (formKey.currentState?.validate() != true) return;
            final uri = Uri.http(widget.address, '/$mode', {
              'ssid': ssidController.text,
              'password': passwordController.text
            });
            await get(uri);
            if (mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class SensorConfigurationDialog extends StatefulWidget {
  final String address;

  const SensorConfigurationDialog({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<SensorConfigurationDialog> createState() =>
      _SensorConfigurationDialogState();
}

class _SensorConfigurationDialogState extends State<SensorConfigurationDialog> {
  var refreshRateLevel = '3';
  var baudRate = '460800';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sensor Configuration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Refresh Rate'),
            trailing: DropdownButton<String>(
              value: refreshRateLevel,
              items: {
                '1': '1Hz',
                '2': '2Hz',
                '3': '4Hz',
                '4': '8Hz',
                '5': '16Hz',
              }
                  .entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => refreshRateLevel = v!),
            ),
          ),
          ListTile(
            title: const Text('Baud Rate'),
            trailing: DropdownButton<String>(
              value: baudRate,
              items: [
                '115200',
                '230400',
                '460800',
                '921600',
              ]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => baudRate = v!),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Apply'),
          onPressed: () async {
            final uri = Uri.http(widget.address, '/rate', {
              'refresh_level': refreshRateLevel,
              'baud_rate': baudRate,
            });
            await get(uri);
            if (mounted) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
