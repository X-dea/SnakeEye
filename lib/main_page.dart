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

import 'connect_page.dart';
import 'connection.dart';
import 'firmware.dart';
import 'opencv_page.dart';
import 'pixels_page.dart';
import 'setting.dart';

class MainPage extends StatelessWidget {
  final Connection connection;

  const MainPage({super.key, required this.connection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SnakeEye'),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: connection.runtimeType.toString(),
            onPressed: () {
              connection.disconnect();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ConnectPage(),
                ),
              );
            },
          )
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.pix),
            title: const Text('Pixels View'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PixelsPage(connection: connection),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('OpenCV View'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OpenCVPage(connection: connection),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => SettingsDialog.show(context, connection),
          ),
          ListTile(
            leading: const Icon(Icons.memory),
            title: const Text('Firmware'),
            onTap: () => FirmwareDialog.show(context, connection),
          ),
        ],
      ),
    );
  }
}
