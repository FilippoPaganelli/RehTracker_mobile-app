// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile(
      {required Key key, required this.result, required this.onTap})
      : super(key: key);

  final ScanResult result;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return '';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return '';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: ElevatedButton(
        onPressed: (result.advertisementData.connectable) ? onTap : null,
        child: const Text('CONNECT'),
      ),
      children: <Widget>[
        _buildAdvRow(
            context, 'Complete Local Name', result.advertisementData.localName),
        _buildAdvRow(context, 'Tx Power Level',
            '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
        _buildAdvRow(context, 'Manufacturer Data',
            getNiceManufacturerData(result.advertisementData.manufacturerData)),
        _buildAdvRow(
            context,
            'Service UUIDs',
            (result.advertisementData.serviceUuids.isNotEmpty)
                ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
                : 'N/A'),
        _buildAdvRow(context, 'Service Data',
            getNiceServiceData(result.advertisementData.serviceData)),
      ],
    );
  }
}

class ServiceTile extends StatelessWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile(
      {required Key key,
      required this.service,
      required this.characteristicTiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (characteristicTiles.isNotEmpty) {
      var serviceName = ('Exercise:');
      return ExpansionTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              serviceName,
              style: GoogleFonts.sora(fontSize: 18),
            ),
          ],
        ),
        children: characteristicTiles,
      );
    } else {
      return ListTile(
        title: const Text('Unknown'),
        subtitle:
            Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}'),
      );
    }
  }
}

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;

  const CharacteristicTile({required Key key, required this.characteristic})
      : super(key: key);

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  var mainCharButtonText = 'Start';

  String _getType(List<int>? value) {
    if (value == null || value.isEmpty || value.last == 1) {
      return 'Muscle contraction';
    }

    return 'Wrist rotation';
  }

  @override
  Widget build(BuildContext context) {
    bool isMainChar = (widget.characteristic.uuid.toString().toLowerCase() ==
        'b964a50a-20fa-4d37-97eb-971bf5233a98');
    String charName = isMainChar ? 'Value' : 'Type';

// MUSCLE EXERCISE
    if (isMainChar) {
      widget.characteristic.setNotifyValue(true);
      return StreamBuilder<List<int>>(
        stream: widget.characteristic.value,
        initialData: widget.characteristic.lastValue,
        builder: (c, snapshot) {
          final value = snapshot.data;
          return ExpansionTile(
            title: ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    charName,
                    style: GoogleFonts.sora(fontSize: 17),
                  ),
                ],
              ),
              subtitle: Text((value == null || value.isEmpty)
                  ? '-'
                  : value.first.toString()),
              contentPadding: const EdgeInsets.all(0.0),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                OutlinedButton(
                  child: Text(
                    mainCharButtonText,
                    style: GoogleFonts.sora(fontSize: 17),
                  ),
                  onPressed: () {
                    try {
                      setState(() {
                        if (mainCharButtonText == 'Start') {
                          mainCharButtonText = 'End';
                        } else {
                          mainCharButtonText = 'Start';
                        }
                      });
                    } catch (e) {
                      print('error');
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    } else
// ROTATION EXERCISE
    {
      return StreamBuilder<List<int>>(
        stream: widget.characteristic.value,
        initialData: widget.characteristic.lastValue,
        builder: (c, snapshot) {
          final value = snapshot.data;
          return ExpansionTile(
            title: ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    charName,
                    style: GoogleFonts.sora(fontSize: 17),
                  ),
                ],
              ),
              subtitle: Text(_getType(value)),
              contentPadding: const EdgeInsets.all(0.0),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                OutlinedButton(
                  child: Text(
                    'Change',
                    style: GoogleFonts.sora(fontSize: 17),
                  ),
                  onPressed: () async {
                    await widget.characteristic.read();
                    await widget.characteristic.write(
                        widget.characteristic.lastValue.last == 1 ? [0] : [1],
                        withoutResponse: false);
                    await widget.characteristic.read();
                  },
                ),
              ],
            ),
            // children: descriptorTiles,
          );
        },
      );
    }
  }
}

class DescriptorTile extends StatelessWidget {
  final BluetoothDescriptor descriptor;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;

  const DescriptorTile(
      {required Key key,
      required this.descriptor,
      required this.onReadPressed,
      required this.onWritePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Descriptor'),
          Text(
            '0x${descriptor.uuid.toString().toUpperCase().substring(4, 8)}',
          )
        ],
      ),
      subtitle: StreamBuilder<List<int>>(
        stream: descriptor.value,
        initialData: descriptor.lastValue,
        builder: (c, snapshot) => Text(snapshot.data.toString()),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.file_download,
              // color: Theme.of(context).iconTheme.color.withOpacity(0.5),
            ),
            onPressed: onReadPressed,
          ),
          IconButton(
            icon: const Icon(
              Icons.file_upload,
              // color: Theme.of(context).iconTheme.color.withOpacity(0.5),
            ),
            onPressed: onWritePressed,
          )
        ],
      ),
    );
  }
}

class AdapterStateTile extends StatelessWidget {
  const AdapterStateTile({required Key key, required this.state})
      : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: ListTile(
        title: Text(
          'Bluetooth adapter is ${state.toString().substring(15)}',
          // style: Theme.of(context).primaryTextTheme.subhead,
        ),
        trailing: const Icon(
          Icons.error,
          // color: Theme.of(context).primaryTextTheme.subhead.color,
        ),
      ),
    );
  }
}
