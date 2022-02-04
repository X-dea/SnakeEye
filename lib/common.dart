// Copyright (C) 2020-2021 Jason C.H.

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

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

const sensorWidth = 32;
const sensorHeight = 24;
const sensorResolution = sensorWidth * sensorHeight;
const ratio = sensorWidth / sensorHeight;

const upscaledWidth = 320;
const upscaledHeight = 240;
const upscaledResolution = upscaledWidth * upscaledHeight;

final inputTemperatures = malloc.allocate<Uint8>(sensorResolution * 4);
final composedImage = malloc.allocate<Uint8>(upscaledResolution * 4);

late DynamicLibrary lib;
late void Function(Pointer<Uint8>, Pointer<Uint8>) composeImage;

void initFFI() {
  if (Platform.isAndroid) {
    lib = DynamicLibrary.open('libSnakeEye.so');
  } else {
    lib = DynamicLibrary.executable();
  }
  composeImage = lib.lookupFunction<
      Void Function(Pointer<Uint8>, Pointer<Uint8>),
      void Function(Pointer<Uint8>, Pointer<Uint8>)>('ComposeImage');

  // lib.lookupFunction<
  //     Void Function(Pointer<Void>),
  //     void Function(
  //         Pointer<Void>)>('InitializeDartApi')(NativeApi.initializeApiDLData);
}
