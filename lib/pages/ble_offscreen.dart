import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colours.dart' as colours;

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({super.key, required this.state});

  final BluetoothState state;

  String _getStatusText(BluetoothState state) {
    final formattedState = state.toString().substring(15);
    return formattedState == 'turningOn'
        ? 'turning on'
        : formattedState == 'turningOff'
            ? 'turning off'
            : state.toString().substring(15);
  }

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
                'Bluetooth is ${_getStatusText(state)}.',
                style: GoogleFonts.sora(fontSize: 22, color: Colors.white),
              ),
            ],
          ),
        ));
  }
}
