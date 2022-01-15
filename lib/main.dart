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
              const VerticalDivider(color: Colors.transparent),
              ElevatedButton(
                child: const Text('Configure'),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ConfigurationDialog(
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

class ConfigurationDialog extends StatefulWidget {
  final String address;

  const ConfigurationDialog({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<ConfigurationDialog> createState() => _ConfigurationDialogState();
}

class _ConfigurationDialogState extends State<ConfigurationDialog> {
  final formKey = GlobalKey<FormState>();
  var mode = 'ap';
  var ssidController = TextEditingController(text: 'SnakeEye');
  var passwordController = TextEditingController(text: '5nakeEye');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configuration'),
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
