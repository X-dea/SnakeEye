// Copyright (C) 2020-2025 Jason C.H.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'connect_page.dart';

void main() {
  runApp(const App());

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnakeEye',
      theme: ThemeData(colorSchemeSeed: Colors.redAccent, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.redAccent,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const ConnectPage(),
    );
  }
}
