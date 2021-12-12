import 'dart:ffi';

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

void initFfi() {
  lib = DynamicLibrary.executable();
  composeImage = lib.lookupFunction<
      Void Function(Pointer<Uint8>, Pointer<Uint8>),
      void Function(Pointer<Uint8>, Pointer<Uint8>)>('ComposeImage');

  lib.lookupFunction<
      Void Function(Pointer<Void>),
      void Function(
          Pointer<Void>)>('InitializeDartApi')(NativeApi.initializeApiDLData);
}
