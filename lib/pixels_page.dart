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

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'common.dart';
import 'connection.dart';
import 'interpolation.dart';

class PixelsPage extends StatefulWidget {
  final Connection connection;

  const PixelsPage({super.key, required this.connection});

  @override
  State<PixelsPage> createState() => _PixelsPageState();
}

class _PixelsPageState extends State<PixelsPage> {
  final tween = ColorTween(begin: Colors.blue, end: Colors.red);
  var maxTemp = -273.15;
  var minTemp = -273.15;
  var diff = 0.0;
  var _scale = 1;
  var _displayWidth = sensorWidth;
  var _displayHeight = sensorHeight;
  Float32List? _temps;
  StreamSubscription? _framesSubscription;

  void processTemperatures(Float32List t) {
    var temps = _temps = t;
    if (_displayWidth != sensorWidth || _displayHeight != sensorHeight) {
      temps = _temps = interpolate(
        temps,
        targetWidth: _displayWidth,
        targetHeight: _displayHeight,
      );
    }
    maxTemp = temps.reduce(max);
    minTemp = temps.reduce(min);
    diff = maxTemp - minTemp;

    if (mounted) setState(() {});
  }

  void _initFrames() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _framesSubscription = widget.connection.receiveFrames().listen(
      (event) => processTemperatures(event),
    );
  }

  @override
  void initState() {
    _initFrames();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    widget.connection.stopFrames();
    _framesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grids = LayoutBuilder(
      builder: (context, constraints) {
        final pixelExtent = min(
          (constraints.maxWidth - 6) / _displayWidth,
          (constraints.maxHeight - 6) / _displayHeight,
        );

        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(
            vertical: max(
              0,
              (constraints.maxHeight - (pixelExtent * _displayHeight)) / 2,
            ),
            horizontal: max(
              0,
              (constraints.maxWidth - (pixelExtent * _displayWidth)) / 2,
            ),
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _displayWidth,
            mainAxisExtent: pixelExtent,
          ),
          itemCount: _displayWidth * _displayHeight,
          itemBuilder: (context, i) {
            final temp = _temps![i];
            final color = tween.lerp((temp - minTemp) / max(10, diff))!;

            return Container(
              width: pixelExtent,
              height: pixelExtent,
              decoration: BoxDecoration(
                color: color,
                border: temp == maxTemp
                    ? Border.all(color: Colors.yellowAccent, width: 2.0)
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
      body: Stack(
        children: [
          if (_temps != null)
            Directionality(
              // Flip sensor around y-axis.
              textDirection: TextDirection.rtl,
              child: grids,
            ),
          if (_temps != null)
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '↑ ${maxTemp.toStringAsFixed(2)}°C\n'
                  '↓ ${minTemp.toStringAsFixed(2)}°C\n'
                  'Δ ${diff.toStringAsFixed(2)}°C',
                ),
              ),
            ),
          if (_temps == null)
            const Center(child: CircularProgressIndicator.adaptive()),
        ],
      ),
      floatingActionButton: SpeedDial(
        mini: true,
        renderOverlay: false,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.zoom_in_map),
            onTap: () {
              _scale = max(1, _scale - 1);
              _displayWidth = sensorWidth * _scale;
              _displayHeight = sensorHeight * _scale;
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.zoom_out_map),
            onTap: () {
              _scale = min(2, _scale + 1);
              _displayWidth = sensorWidth * _scale;
              _displayHeight = sensorHeight * _scale;
            },
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
