// Copyright (C) 2020-2025 Jason C.H.

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

import 'package:ffi/ffi.dart';

const sensorWidth = 32;
const sensorHeight = 24;
const sensorPixels = sensorWidth * sensorHeight;
const rawFrameLength = sensorPixels * 4;
const ratio = sensorWidth / sensorHeight;

const upscaledWidth = 320;
const upscaledHeight = 240;
const upscaledPixels = upscaledWidth * upscaledHeight;

final inputTemperatures = malloc.allocate<Uint8>(sensorPixels * 4);
final outputImage = malloc.allocate<Uint8>(upscaledPixels * 4);

late DynamicLibrary lib;
late void Function(Pointer<Uint8>, Pointer<Uint8>) processImage;
