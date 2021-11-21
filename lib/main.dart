import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

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
      home: const ConfigPage(),
    );
  }
}

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  var _address = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Address',
            ),
            onChanged: (v) => _address = v,
          ),
          ElevatedButton(
            child: const Text('Connect'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SensorPage(
                  address: _address,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SensorPage extends StatefulWidget {
  final String address;

  const SensorPage({Key? key, required this.address}) : super(key: key);

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  Float32List temps = Float32List(768);
  List<double> pixels = [];

  void refresh() async {
    var resp = await get(Uri.parse(widget.address));
    temps = Uint8List.fromList(resp.bodyBytes).buffer.asFloat32List();
    pixels = temps.map((e) => e / 45).toList();
    setState(() {});
    refresh();
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor'),
      ),
      body: GridView(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 32),
        children: [
          for (var i in pixels)
            Container(
              color: ColorTween(
                begin: Colors.blue,
                end: Colors.redAccent,
              ).lerp(i.isNaN ? 0 : i),
              child: Text((i * 45).toStringAsFixed(2)),
            )
        ],
      ),
    );
  }
}
