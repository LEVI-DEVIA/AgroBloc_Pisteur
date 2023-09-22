import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Ble(),
    );
  }
}

class Ble extends StatefulWidget {
  @override
  _BleState createState() => _BleState();
}

class _BleState extends State<Ble> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> bleDevices = [];

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name.contains("BLE232")) {
          if (!bleDevices.contains(result.device)) {
            setState(() {
              bleDevices.add(result.device);
            });
          }
        }
      }
    });

    flutterBlue.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Périphériques BLE232'),
      ),
      body: ListView.builder(
        itemCount: bleDevices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(bleDevices[index].name),
            subtitle: Text(bleDevices[index].id.toString()),
            onTap: () {
              // Vous pouvez ajouter des actions à effectuer lorsque l'utilisateur appuie sur un périphérique de la liste.
              // Par exemple, se connecter au périphérique ou afficher plus d'informations.
            },
          );
        },
      ),
    );
  }
}
