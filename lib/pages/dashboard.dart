import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rehtracker_flutter/pages/ble_device.dart';
import 'package:rehtracker_flutter/pages/ble_offscreen.dart';
import 'package:rehtracker_flutter/pages/widgets.dart';
import '../utils/colours.dart' as colours;

class Dashboard extends StatefulWidget {
  final FlutterBlue flutterBlue;

  const Dashboard({Key? key, required this.flutterBlue}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkBluetoothConnectPermission() async {
    Permission.bluetoothConnect.status.then((status) async {
      if (status.isGranted) {
        return;
      }
      if (!status.isGranted) {
        Permission.bluetoothConnect.request();
      }
    });
  }

  Future<void> _checkBluetoothScanPermission() async {
    Permission.bluetoothScan.status.then((status) async {
      if (status.isGranted) {
        return;
      }
      if (!status.isGranted) {
        Permission.bluetoothScan.request();
      }
    });
  }

  Future<void> _checkLocationPermission() async {
    Permission.locationWhenInUse.status.then((status) async {
      if (status.isGranted) {
        return;
      }
      if (!status.isGranted) {
        Permission.locationWhenInUse.request();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Builder(builder: (context) {
          return StreamBuilder<BluetoothState>(
              stream: widget.flutterBlue.state,
              initialData: BluetoothState.unknown,
              builder: (c, snapshot) {
                final state = snapshot.data;

                _checkBluetoothScanPermission();
                _checkBluetoothConnectPermission();
                _checkLocationPermission();

                if (state == BluetoothState.on) {
                  return FindDevicesScreen(flutterBlue: widget.flutterBlue);
                }

                return BluetoothOffScreen(
                  state: state!,
                  key: Key(UniqueKey().toString()),
                );
              });
        }),
        onWillPop: () async => false);
  }
}

class FindDevicesScreen extends StatefulWidget {
  final FlutterBlue flutterBlue;

  const FindDevicesScreen({Key? key, required this.flutterBlue})
      : super(key: key);

  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  BluetoothDevice? consoleDevice;
  final List<BluetoothDevice> devices = [];

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
            widget.flutterBlue.startScan(timeout: const Duration(seconds: 3)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(const Duration(seconds: 2))
                    .asyncMap((_) => widget.flutterBlue.connectedDevices),
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: (snapshot.data ?? [])
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
                stream: widget.flutterBlue.scanResults,
                initialData: const [],
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
        stream: widget.flutterBlue.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data!) {
            return FloatingActionButton(
              onPressed: () => widget.flutterBlue.stopScan(),
              backgroundColor: colours.GRADIENT_4,
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
              backgroundColor: colours.GRADIENT_2,
              child: const Icon(Icons.search),
              onPressed: () => widget.flutterBlue.startScan(
                  timeout: const Duration(seconds: 5), allowDuplicates: false),
            );
          }
        },
      ),
    );
  }
}
