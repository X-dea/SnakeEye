import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart' hide Image;
import 'package:http/http.dart';

import 'interpolation.dart';

const sensorWidth = 32;
const sensorHeight = 24;
const displayWidth = 64;
const displayHeight = 48;

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnakeEye',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var controller = TextEditingController(text: 'http://');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Address',
              ),
              controller: controller,
            ),
          ),
          ElevatedButton(
            child: const Text('Connect'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SensorPage(
                  address: controller.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Cell {
  final double temperature;
  final Color color;

  const Cell(this.temperature, this.color);
}

class SensorPage extends StatefulWidget {
  final String address;

  const SensorPage({Key? key, required this.address}) : super(key: key);

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  var temps = Float32List(sensorWidth * sensorHeight);
  var maxTemp = -273.15;
  var minTemp = -273.15;
  var diff = 0.0;
  var cells = <Cell>[];

  void refresh() async {
    try {
      var resp = await get(Uri.parse(widget.address));
      temps = Uint8List.fromList(resp.bodyBytes).buffer.asFloat32List();

      temps = interpolate(
        temps,
        targetWidth: displayWidth,
        targetHeight: displayHeight,
      );

      maxTemp = temps.reduce(max);
      minTemp = temps.reduce(min);
      diff = maxTemp - minTemp;

      cells = temps
          .map((e) => Cell(
                e,
                ColorTween(
                  begin: Colors.blue,
                  end: Colors.red,
                ).lerp((e - minTemp) / max(30, diff))!,
              ))
          .toList();

      if (mounted) setState(() {});
    } finally {
      refresh();
    }
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) return const Center(child: CircularProgressIndicator());

    final sensorArea = LayoutBuilder(
      builder: (context, constraints) {
        final pixelExtent = min(
          (constraints.maxWidth - 16) / displayWidth,
          (constraints.maxHeight - 16) / displayHeight,
        );

        return GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: max(
              8,
              (constraints.maxWidth - (pixelExtent * displayWidth)) / 2,
            ),
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: displayWidth,
            mainAxisExtent: pixelExtent,
          ),
          itemCount: displayWidth * displayHeight,
          itemBuilder: (context, i) {
            final c = cells[i];
            return Container(
              width: pixelExtent,
              height: pixelExtent,
              decoration: BoxDecoration(
                color: c.color,
                border: c.temperature == maxTemp
                    ? Border.all(color: Colors.yellow, width: 2.0)
                    : c.temperature == minTemp
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
          Text(
            'MAX: ${maxTemp.toStringAsFixed(2)} '
            'MIN: ${minTemp.toStringAsFixed(2)} '
            'DIFF: ${diff.toStringAsFixed(2)}',
          ),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: sensorArea,
            ),
          ),
        ],
      ),
    );
  }
}
