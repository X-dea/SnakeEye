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

import 'dart:async';
import 'dart:ffi' hide Size;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'common.dart';
import 'connection.dart';

class OpenCVPage extends StatefulWidget {
  final Connection connection;

  const OpenCVPage({
    Key? key,
    required this.connection,
  }) : super(key: key);

  @override
  State<OpenCVPage> createState() => _OpenCVPageState();
}

class _OpenCVPageState extends State<OpenCVPage> {
  var maxTemp = -273.15;
  var minTemp = -273.15;
  var diff = 0.0;

  Image? image;
  StreamSubscription? _framesSubscription;

  CameraController? _cameraController;
  var _enableCameraControl = false;
  var _cameraOffset = Offset.zero;

  void processTemperatures(Float32List temps) async {
    inputTemperatures
        .asTypedList(sensorPixels * 4)
        .buffer
        .asFloat32List()
        .setAll(0, temps);

    processImage(inputTemperatures, outputImage);
    decodeImageFromPixels(
      outputImage.asTypedList(upscaledPixels * 4),
      upscaledWidth,
      upscaledHeight,
      PixelFormat.bgra8888,
      (img) {
        image?.dispose();
        image = img;

        maxTemp = temps.reduce(max);
        minTemp = temps.reduce(min);
        diff = maxTemp - minTemp;

        if (mounted) setState(() {});
      },
    );
  }

  void _initFrames() {
    _framesSubscription = widget.connection
        .receiveFrames()
        .listen((event) => processTemperatures(event));
  }

  void _toggleCamera() async {
    var controller = _cameraController;
    if (controller == null) {
      final cameras = await availableCameras();
      controller = _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.max,
        enableAudio: false,
      );
      await controller.initialize();
    } else {
      _cameraController = null;
      await controller.dispose();
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initFrames();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    widget.connection.stopFrames();
    _framesSubscription?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = this.image;
    final controller = _cameraController;
    final isCameraInitialized =
        controller != null && controller.value.isInitialized;
    return Scaffold(
      body: Stack(
        children: [
          if (isCameraInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Transform.translate(
                  offset: _cameraOffset,
                  child: GestureDetector(
                    onPanUpdate: (d) {
                      if (_enableCameraControl) _cameraOffset += d.delta * 0.5;
                    },
                    child: CameraPreview(controller),
                  ),
                ),
              ),
            ),
          if (image != null)
            IgnorePointer(
              child: LayoutBuilder(builder: (context, constraints) {
                return RawImage(
                  image: image,
                  opacity: isCameraInitialized
                      ? const AlwaysStoppedAnimation(0.6)
                      : null,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  fit: BoxFit.contain,
                );
              }),
            ),
          if (image != null)
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '↑ ${maxTemp.toStringAsFixed(2)}°C\n'
                  '↓ ${minTemp.toStringAsFixed(2)}°C\n'
                  'Δ ${diff.toStringAsFixed(2)}°C',
                ),
              ),
            ),
          if (controller == null && image == null)
            const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
        ],
      ),
      floatingActionButton: SpeedDial(
        mini: true,
        renderOverlay: false,
        children: [
          if (controller != null)
            SpeedDialChild(
              child: Icon(
                Icons.control_camera,
                color: _enableCameraControl
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).iconTheme.color,
              ),
              onTap: () =>
                  setState(() => _enableCameraControl = !_enableCameraControl),
            ),
          SpeedDialChild(
            child: Icon(
              Icons.camera_alt,
              color: _cameraController != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).iconTheme.color,
            ),
            onTap: _toggleCamera,
          ),
          SpeedDialChild(
            child: const Icon(Icons.arrow_back),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
        activeChild: const Icon(Icons.close),
        child: const Icon(Icons.construction),
      ),
    );
  }
}
