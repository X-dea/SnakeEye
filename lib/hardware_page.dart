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

import 'dart:convert';

import 'package:espota/espota.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ulink/ulink.dart';

import 'connection.dart';
import 'setting.dart';

class HardwarePage extends StatefulWidget {
  final Connection connection;

  const HardwarePage({super.key, required this.connection});

  @override
  State<HardwarePage> createState() => _HardwarePageState();
}

class _HardwarePageState extends State<HardwarePage> {
  SnakeEyeSettings? _settings;
  final _releases = <String, Map<String, String>>{};

  Future<void> _loadSettings() async {
    _settings = await widget.connection.settings;
    if (mounted) setState(() {});
  }

  Future<void> _loadReleases() async {
    final resp = await get(
      Uri.parse('https://api.github.com/repos/X-dea/SnakeEye/releases'),
    );
    final list = jsonDecode(resp.body) as List;
    for (final release in list) {
      final files = <String, String>{};
      for (final asset in release['assets']) {
        final name = asset['name'] as String;
        if (!name.endsWith('.bin')) continue;
        files[name] = asset['browser_download_url'];
      }
      if (files.isNotEmpty) _releases[release['name']] = files;
    }
    if (mounted) setState(() {});
  }

  Future<void> _flash(String url) async {
    final conn = widget.connection;
    if (conn.channel is! UdpChannel) return;

    await showDialog(
      context: context,
      builder: (context) => _Flasher(
        connection: conn,
        url: url,
      ),
    );
  }

  @override
  void initState() {
    _loadSettings();
    _loadReleases();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hardware'),
      ),
      body: ListView(
        children: [
          if (settings != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Current',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              title: const Text('Firmware'),
              trailing: Text(
                '${settings.version ~/ 10000}.${settings.version % 10000 ~/ 100}.${settings.version % 100}',
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Releases',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final release in _releases.entries)
            for (final file in release.value.entries)
              ListTile(
                title: Text(file.key),
                subtitle: Text(release.key),
                onTap: () => _flash(file.value),
              ),
        ],
      ),
    );
  }
}

class _Flasher extends StatefulWidget {
  final Connection connection;
  final String url;

  const _Flasher({
    required this.connection,
    required this.url,
  });

  @override
  State<_Flasher> createState() => _FlasherState();
}

class _FlasherState extends State<_Flasher> {
  double? _progress;

  Future<void> _update() async {
    final resp = await get(Uri.parse(widget.url));
    final fw = resp.bodyBytes;

    if (mounted) {
      setState(() => _progress = 0);
    } else {
      return;
    }

    final address = (widget.connection.channel as UdpChannel).address;
    final progress = await upgrade(address, fw.buffer.asUint8List());
    try {
      await for (final p in progress) {
        if (mounted) setState(() => _progress = p);
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Done'),
        ));
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    }
  }

  @override
  void initState() {
    _update();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(_progress == null ? 'Downloading' : 'Flashing'),
      contentPadding: const EdgeInsets.all(16),
      children: [
        LinearProgressIndicator(value: _progress),
      ],
    );
  }
}
