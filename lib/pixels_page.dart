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

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'common.dart';
import 'connection.dart';
import 'interpolation.dart';

class PixelsPage extends StatefulWidget {
  final Connection connection;

  const PixelsPage({
    Key? key,
    required this.connection,
  }) : super(key: key);

  @override
  State<PixelsPage> createState() => _PixelsPageState();
}

class _PixelsPageState extends State<PixelsPage> {
  final tween = ColorTween(begin: Colors.blue, end: Colors.red);
  late final int displayWidth;
  late final int displayHeight;

  var maxTemp = -273.15;
  var minTemp = -273.15;
  var diff = 0.0;
  var temps = Float32List(0);

  void processTemperatures(Float32List t) {
    temps = t;
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

  @override
  void initState() {
    displayWidth = sensorWidth;
    displayHeight = sensorHeight;
    widget.connection
        .receiveFrames()
        .listen((event) => processTemperatures(event));
    super.initState();
  }

  @override
  void dispose() {
    widget.connection.stopFrames();
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
      appBar: Platform.isAndroid
          ? null
          : AppBar(
              title: const Text('Sensor'),
            ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: diff != 0.0
                  ? Directionality(
                      // Flip sensor around y-axis.
                      textDirection: TextDirection.rtl,
                      child: sensorArea,
                    )
                  : const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
            ),
            if (diff != 0.0)
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
      ),
    );
  }
}
