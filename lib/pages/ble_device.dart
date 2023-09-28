import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rehtracker_flutter/pages/widgets.dart';
import '../utils/colours.dart' as colours;

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({required Key key, required this.device})
      : super(key: key);

  final BluetoothDevice device;

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .where((service) =>
            service.uuid.toString().toLowerCase() ==
            '0ccc7966-1399-4c67-9ede-9b05dbea1ba2')
        .map(
          (service) => ServiceTile(
            service: service,
            characteristicTiles: service.characteristics
                .map(
                  (characteristic) => CharacteristicTile(
                    key: Key(UniqueKey().toString()),
                    characteristic: characteristic,
                  ),
                )
                .toList(),
            key: Key(UniqueKey().toString()),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(255, 2, 117, 146),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
        backgroundColor: colours.GRADIENT_2,
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = () => {};
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: colours.GRADIENT_2),
                child: Text(text),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => Builder(builder: (context) {
                device.discoverServices();
                return ListTile(
                  leading: (snapshot.data == BluetoothDeviceState.connected)
                      ? const Icon(Icons.bluetooth_connected)
                      : const Icon(Icons.bluetooth_disabled),
                  title: Text(
                      'Device is ${snapshot.data.toString().split('.')[1]}'),
                  subtitle: const Text('Ready to start the exercise'),
                );
              }),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
