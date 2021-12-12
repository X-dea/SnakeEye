import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;

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

class UpscaledSensorPage extends StatefulWidget {
  final String address;

  const UpscaledSensorPage({Key? key, required this.address}) : super(key: key);

  @override
  State<UpscaledSensorPage> createState() => _UpscaledSensorPageState();
}

class _UpscaledSensorPageState extends State<UpscaledSensorPage> {
  var temps = Float32List(sensorWidth * sensorHeight);
  var maxTemp = -273.15;
  var minTemp = -273.15;
  var diff = 0.0;

  late RawDatagramSocket socket;
  Image? image;

  void refresh() async {
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 55544);
    socket.send([0x1], InternetAddress(widget.address), 55544);

    await for (var p in socket) {
      if (p != RawSocketEvent.read) continue;

      final dg = socket.receive();
      if (dg == null || dg.data.lengthInBytes != sensorResolution * 4) continue;

      temps = dg.data.buffer.asFloat32List();

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
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    socket.send([0x0], InternetAddress(widget.address), 55544);
    socket.close();
    super.dispose();
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
