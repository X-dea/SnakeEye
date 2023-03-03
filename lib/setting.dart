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
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

import 'connection.dart';

part 'setting.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SnakeEyeSettings extends _SnakeEyeSettings with _$SnakeEyeSettings {
  final int version;

  SnakeEyeSettings(this.version);

  factory SnakeEyeSettings.fromJson(Map<String, dynamic> json) =>
      _$SnakeEyeSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SnakeEyeSettingsToJson(this);
}

abstract class _SnakeEyeSettings with Store {
  @observable
  int wifiMode = 0;

  @observable
  String ssid = 'SnakeEye';

  @observable
  String password = '5nakeEye';

  @observable
  int? refreshRateLevel;

  @observable
  int? serialBaudRate;
}

class SettingsDialog extends StatefulWidget {
  final Connection connection;

  const SettingsDialog({super.key, required this.connection});

  static Future<void> show(BuildContext context, Connection connection) async {
    await showDialog(
      context: context,
      builder: (context) => SettingsDialog(connection: connection),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  static final _refreshRateMap = {
    1: '1Hz',
    2: '2Hz',
    3: '4Hz',
    4: '8Hz',
    5: '16Hz',
  };

  static final _supportedSerialBaudRates = [
    115200,
    230400,
    460800,
    921600,
  ];

  SnakeEyeSettings? _settings;

  Future<void> _load() async {
    _settings = await widget.connection.settings;
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    await widget.connection.saveSettings(_settings!);
    if (mounted) Navigator.of(context).pop();
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

    return Observer(
      builder: (context) => SimpleDialog(
        title: const Text('Settings'),
        contentPadding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Refresh Rate'),
            trailing: DropdownButton<int>(
              value: settings.refreshRateLevel,
              items: _refreshRateMap.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (v) => settings.refreshRateLevel = v!,
            ),
          ),
          ListTile(
            title: const Text('Serial Baud Rate'),
            trailing: DropdownButton<int>(
              value: settings.serialBaudRate,
              items: _supportedSerialBaudRates
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.toString()),
                      ))
                  .toList(),
              onChanged: (v) => settings.serialBaudRate = v!,
            ),
          ),
          ListTile(
            title: const Text('WiFi Mode'),
            trailing: DropdownButton<int>(
              value: settings.wifiMode,
              items: const [
                DropdownMenuItem(value: 0, child: Text('AP')),
                DropdownMenuItem(value: 1, child: Text('STA')),
              ],
              onChanged: (v) => settings.wifiMode = v!,
            ),
          ),
          TextFormField(
            initialValue: settings.ssid,
            maxLength: 30,
            decoration: const InputDecoration(labelText: 'WiFi SSID'),
            validator: (v) => v == null || v.isEmpty || v.length >= 30
                ? 'Invalid SSID'
                : null,
            onChanged: (v) => settings.ssid = v,
          ),
          TextFormField(
            initialValue: settings.password,
            maxLength: 30,
            decoration: const InputDecoration(labelText: 'WiFi Password'),
            validator: (v) => v == null || v.length < 8 || v.length >= 30
                ? 'Invalid password'
                : null,
            onChanged: (v) => settings.password = v,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
