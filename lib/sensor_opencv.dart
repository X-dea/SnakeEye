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

import 'dart:ffi' hide Size;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:snake_eye/connection.dart';

import 'common.dart';

class ImagePainter extends CustomPainter {
  final Image image;
  final double opacity;

  const ImagePainter({
    required this.image,
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: image,
      fit: size.aspectRatio > ratio ? BoxFit.fitHeight : BoxFit.fitWidth,
      opacity: opacity,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class OpenCVSensorPage extends StatefulWidget {
  final String address;
  final bool cameraPreview;

  const OpenCVSensorPage({
    Key? key,
    required this.address,
    this.cameraPreview = false,
  }) : super(key: key);

  @override
  State<OpenCVSensorPage> createState() => _OpenCVSensorPageState();
}

class _OpenCVSensorPageState extends State<OpenCVSensorPage>
    with ConnectionProcessor {
  var maxTemp = -273.15;
  var minTemp = -273.15;
  var diff = 0.0;

  Image? image;
  CameraController? controller;

  @override
  String get address => widget.address;

  @override
  void processTemperatures(Float32List temps) async {
    inputTemperatures
        .asTypedList(sensorPixels * 4)
        .buffer
        .asFloat32List()
        .setAll(0, temps);

    composeImage(inputTemperatures, composedImage);
    decodeImageFromPixels(
      composedImage.asTypedList(upscaledResolution * 4),
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

  void initCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(
      cameras.first,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await controller?.initialize();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    if (widget.cameraPreview) initCamera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final image = this.image;
    final controller = this.controller;
    return Scaffold(
      appBar: Platform.isAndroid ? null : AppBar(title: const Text('Sensor')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (controller != null && controller.value.isInitialized)
                    Center(
                      child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: Transform.translate(
                          offset: const Offset(-60, 0),
                          child: CameraPreview(controller),
                        ),
                      ),
                    ),
                  if (image != null)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return CustomPaint(
                          painter: ImagePainter(
                            image: image,
                            opacity: widget.cameraPreview ? 0.5 : 1.0,
                          ),
                          size: constraints.biggest,
                        );
                      },
                    ),
                  if (controller == null && image == null)
                    const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                ],
              ),
            ),
            if (image != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      '${minTemp.toStringAsFixed(2)}°C',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 10,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 0, 0, 255),
                            Color.fromARGB(255, 0, 255, 255),
                            Color.fromARGB(255, 255, 255, 0),
                            Color.fromARGB(255, 255, 0, 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    child: Text(
                      '${maxTemp.toStringAsFixed(2)}°C '
                      'Delta: ${diff.toStringAsFixed(2)}°C',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
