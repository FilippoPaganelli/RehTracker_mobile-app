import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rehtracker_flutter/pages/widgets.dart';
import '../utils/colours.dart' as colours;

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  Future<void> _checkPermissions() async {
    final locStatus = await Permission.locationWhenInUse.serviceStatus;
    final isGpsOn = locStatus == ServiceStatus.enabled;
    if (!isGpsOn) {
      return;
    }

    final status = await Permission.locationWhenInUse.request();
    if (status == PermissionStatus.granted) {
      return;
    } else if (status == PermissionStatus.denied) {
      await openAppSettings();
    } else if (status == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder: (c, snapshot) {
              final state = snapshot.data;
              _checkPermissions();
              if (state == BluetoothState.on) {
                return const FindDevicesScreen();
              }
              return BluetoothOffScreen(
                state: state!,
                key: Key(UniqueKey().toString()),
              );
            }),
        onWillPop: () async => false);
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({required this.state, required Key key});

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colours.GRADIENT_2,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 150.0,
              color: Color.fromARGB(187, 255, 255, 255),
            ),
            Text(
              'Bluetooth is ${(state.toString().substring(15) == 'turningOn' ? 'turning on' : state.toString().substring(15))}.',
              style: GoogleFonts.sora(fontSize: 22, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  BluetoothDevice? consoleDevice;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
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
          automaticallyImplyLeading: false,
          title: Text(
            'Dashboard',
            style:
                GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.normal),
          ),
          backgroundColor: colours.GRADIENT_2),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: const Duration(seconds: 5)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(const Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        (d) => ListTile(
                          title: Text(d.name),
                          subtitle: Text(d.id.toString()),
                          trailing: StreamBuilder<BluetoothDeviceState>(
                            stream: d.state,
                            initialData: BluetoothDeviceState.disconnected,
                            builder: (c, snapshot) {
                              if (snapshot.data ==
                                  BluetoothDeviceState.connected) {
                                return ElevatedButton(
                                  child: const Text('OPEN'),
                                  onPressed: () => Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => DeviceScreen(
                                                device: d,
                                                key:
                                                    Key(UniqueKey().toString()),
                                              ))),
                                );
                              }
                              return Text(snapshot.data.toString());
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        (r) => (r.device.name == 'RehTracker - Console')
                            ? ScanResultTile(
                                key: Key(UniqueKey().toString()),
                                result: r,
                                onTap: () => Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  r.device.connect(
                                      autoConnect: true,
                                      timeout: const Duration(seconds: 2));

                                  return DeviceScreen(
                                    device: r.device,
                                    key: Key(UniqueKey().toString()),
                                  );
                                })),
                              )
                            : const Center(),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: colours.GRADIENT_4,
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
                backgroundColor: colours.GRADIENT_2,
                child: const Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: const Duration(seconds: 5)));
          }
        },
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({required Key key, required this.device})
      : super(key: key);

  final BluetoothDevice device;

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .where((s) =>
            s.uuid.toString().toLowerCase() ==
            '0ccc7966-1399-4c67-9ede-9b05dbea1ba2')
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTile(
                    key: Key(UniqueKey().toString()),
                    characteristic: c,
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
                  child: Text(
                    text,
                  ));
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
                  subtitle: Text('Ready to start the exercise'),
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
