// Copyright (C) 2020-2023 Jason C.H.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snake_eye/connect_page.dart';

import 'common.dart';

void main() {
  runApp(const App());

  // Initialize FFI.
  if (Platform.isAndroid) {
    lib = DynamicLibrary.open('libSnakeEye.so');
  } else {
    lib = DynamicLibrary.executable();
  }

  processImage = lib.lookupFunction<
      Void Function(Pointer<Uint8>, Pointer<Uint8>),
      void Function(Pointer<Uint8>, Pointer<Uint8>)>('ProcessImage');
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnakeEye',
      theme: ThemeData(
        colorSchemeSeed: Colors.redAccent,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const ConnectPage(),
    );
  }
}
