import 'package:flutter/material.dart';
import 'package:http/http.dart';

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
