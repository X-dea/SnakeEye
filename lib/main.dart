import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'common.dart';
import 'sensor.dart';
import 'upscaled_sensor.dart';

void main() {
  runApp(const App());
  initFFI();
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
  var controller = TextEditingController(text: '192.168.4.1');
  var scale = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Address',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Slider(
              value: scale.toDouble(),
              label: 'Scale: ${scale.toInt()}',
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => setState(() => scale = v.toInt()),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 10,
            runSpacing: 10,
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
              ElevatedButton(
                child: const Text('Configure Wifi'),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => WifiConfigurationDialog(
                    address: controller.text,
                  ),
                ),
              ),
              ElevatedButton(
                child: const Text('Configure Sensor'),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => SensorConfigurationDialog(
                    address: controller.text,
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

class WifiConfigurationDialog extends StatefulWidget {
  final String address;

  const WifiConfigurationDialog({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<WifiConfigurationDialog> createState() =>
      _WifiConfigurationDialogState();
}

class _WifiConfigurationDialogState extends State<WifiConfigurationDialog> {
  final formKey = GlobalKey<FormState>();
  var mode = 'ap';
  var ssidController = TextEditingController(text: 'SnakeEye');
  var passwordController = TextEditingController(text: '5nakeEye');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Wifi Configuration'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Mode'),
              trailing: DropdownButton<String>(
                value: mode,
                items: const [
                  DropdownMenuItem(
                    value: 'ap',
                    child: Text('AP'),
                  ),
                  DropdownMenuItem(
                    value: 'sta',
                    child: Text('STA'),
                  ),
                ],
                onChanged: (v) => setState(() => mode = v!),
              ),
            ),
            TextFormField(
              maxLength: 20,
              controller: ssidController,
              decoration: const InputDecoration(labelText: 'SSID'),
              validator: (v) => v == null || v.isEmpty || v.length >= 20
                  ? 'Invalid SSID'
                  : null,
            ),
            TextFormField(
              maxLength: 20,
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (v) => v == null || v.length < 8 || v.length >= 20
                  ? 'Invalid password'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Apply'),
          onPressed: () async {
            if (formKey.currentState?.validate() != true) return;
            final uri = Uri.http(widget.address, '/$mode', {
              'ssid': ssidController.text,
              'password': passwordController.text
            });
            await get(uri);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class SensorConfigurationDialog extends StatefulWidget {
  final String address;

  const SensorConfigurationDialog({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<SensorConfigurationDialog> createState() =>
      _SensorConfigurationDialogState();
}

class _SensorConfigurationDialogState extends State<SensorConfigurationDialog> {
  var level = '3';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sensor Configuration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Refresh Rate'),
            trailing: DropdownButton<String>(
              value: level,
              items: {
                '1': '1Hz',
                '2': '2Hz',
                '3': '4Hz',
                '4': '8Hz',
                '5': '16Hz',
              }
                  .entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => level = v!),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Apply'),
          onPressed: () async {
            final uri = Uri.http(widget.address, '/rate', {
              'level': level,
            });
            await get(uri);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
