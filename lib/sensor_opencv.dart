import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:snake_eye/connection.dart';

import 'common.dart';

class ImagePainter extends CustomPainter {
  Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.width, size.height),
      image: image,
      fit: size.aspectRatio > ratio ? BoxFit.fitHeight : BoxFit.fitWidth,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class OpenCVSensorPage extends StatefulWidget {
  final String address;

  const OpenCVSensorPage({Key? key, required this.address}) : super(key: key);

  @override
  State<OpenCVSensorPage> createState() => _OpenCVSensorPageState();
}

class _OpenCVSensorPageState extends State<OpenCVSensorPage>
    with ConnectionProcessor {
  var maxTemp = -273.15;
  var minTemp = -273.15;
  var diff = 0.0;

  Image? image;

  @override
  String get address => widget.address;

  @override
  void processTemperatures(Float32List temps) async {
    inputTemperatures
        .asTypedList(sensorResolution * 4)
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

  @override
  Widget build(BuildContext context) {
    if (image == null) return const Center(child: CircularProgressIndicator());

    final body = LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: ImagePainter(image!),
          size: constraints.biggest,
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor'),
      ),
      body: Column(
        children: [
          Expanded(
            child: body,
          ),
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
    );
  }
}
