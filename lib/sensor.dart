import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'common.dart';
import 'interpolation.dart';

class SensorPage extends StatefulWidget {
  final String address;
  final int scale;

  const SensorPage({
    Key? key,
    required this.address,
    this.scale = 1,
  }) : super(key: key);

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  final tween = ColorTween(begin: Colors.blue, end: Colors.red);
  late final int displayWidth;
  late final int displayHeight;

  var temps = Float32List(sensorWidth * sensorHeight);
  var maxTemp = -273.15;
  var minTemp = -273.15;
  var diff = 0.0;

  late RawDatagramSocket s;

  void refresh() async {
    s = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 55544);
    s.send([0x1], InternetAddress(widget.address), 55544);

    await for (var p in s) {
      if (p != RawSocketEvent.read) continue;

      final dg = s.receive();
      if (dg == null || dg.data.lengthInBytes != sensorResolution * 4) continue;

      temps = dg.data.buffer.asFloat32List();

      if (displayWidth != sensorWidth || displayHeight != sensorHeight) {
        temps = interpolate(
          temps,
          targetWidth: displayWidth,
          targetHeight: displayHeight,
        );
      }

      maxTemp = temps.reduce(max);
      minTemp = temps.reduce(min);
      diff = maxTemp - minTemp;

      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    displayWidth = sensorWidth * widget.scale;
    displayHeight = sensorHeight * widget.scale;
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    s.send([0x0], InternetAddress(widget.address), 55544);
    s.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (diff == 0.0) return const Center(child: CircularProgressIndicator());

    final sensorArea = LayoutBuilder(
      builder: (context, constraints) {
        final pixelExtent = min(
          (constraints.maxWidth - 6) / displayWidth,
          (constraints.maxHeight - 6) / displayHeight,
        );

        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(
            vertical: max(
              3,
              (constraints.maxHeight - (pixelExtent * displayHeight)) / 2,
            ),
            horizontal: max(
              3,
              (constraints.maxWidth - (pixelExtent * displayWidth)) / 2,
            ),
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: displayWidth,
            mainAxisExtent: pixelExtent,
          ),
          itemCount: displayWidth * displayHeight,
          itemBuilder: (context, i) {
            final temp = temps[i];
            final color = tween.lerp((temp - minTemp) / max(10, diff))!;

            return Container(
              width: pixelExtent,
              height: pixelExtent,
              decoration: BoxDecoration(
                color: color,
                border: temp == maxTemp
                    ? Border.all(color: Colors.yellow, width: 2.0)
                    : temp == minTemp
                        ? Border.all(color: Colors.cyanAccent, width: 2.0)
                        : null,
              ),
            );
          },
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
            child: Directionality(
              // Flip sensor around y-axis.
              textDirection: TextDirection.rtl,
              child: sensorArea,
            ),
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
                        Colors.blue,
                        Colors.red,
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
