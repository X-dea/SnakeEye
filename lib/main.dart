import 'package:flutter/material.dart';

import 'common.dart';
import 'sensor.dart';
import 'upscaled_sensor.dart';

void main() {
  runApp(const App());
  initFfi();
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
  var controller = TextEditingController(text: '');
  var scale = 1;

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
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Slider(
              value: scale.toDouble(),
              label: scale.toStringAsFixed(0),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => setState(() => scale = v.toInt()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Connect'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SensorPage(
                      address: controller.text,
                      scale: scale,
                    ),
                  ),
                ),
              ),
              const VerticalDivider(color: Colors.transparent),
              ElevatedButton(
                child: const Text('Connect (OpenCV)'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UpscaledSensorPage(
                      address: controller.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
