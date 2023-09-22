import 'dart:async';
import 'dart:convert';
//import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class WeightService {
  static final FlutterBluetoothSerial _bluetooth =
      FlutterBluetoothSerial.instance;
  static BluetoothState _bluetoothState = BluetoothState.STATE_OFF;
  static BluetoothConnection? _bluetoothConnection;
  static Timer? _timer;

  static init() {
    _bluetooth.state.then((state) {
      _bluetoothState = state;
    });
    _bluetooth.onStateChanged().listen((state) {
      _bluetoothState = state;
    });
  }

  static FlutterBluetoothSerial getFlutterBluetoothSerial() {
    return _bluetooth;
  }

  static bool bluetoothIsEnabled() {
    return _bluetoothState.isEnabled;
  }

  static bool bluetoothIsConnected() {
    return _bluetoothConnection != null && _bluetoothConnection!.isConnected;
  }

  static Future<BluetoothConnection> connect(String address) {
    var result = BluetoothConnection.toAddressPlus(address);
    result.then((connection) {
      _bluetoothConnection = connection;
    });

    return result;
  }

  static Stream<Uint8List>? getInput() {
    if (bluetoothIsConnected()) {
      return _bluetoothConnection!.input;
    }
    return null;
  }

  static void openReception() {
    if (bluetoothIsConnected()) {
      _bluetoothConnection!.output.setNotify(true);

      const oneSec = Duration(seconds: 1);
      _timer = Timer.periodic(oneSec, (Timer t) {
        if (bluetoothIsConnected()) {
          _bluetoothConnection!.output.add(ascii.encode("IP\n"));
        }
      });
    }
  }

  static void closeReception() {
    if (_timer != null) {
      _timer!.cancel();
    }
    if (bluetoothIsConnected()) {
      _bluetoothConnection!.output.setNotify(false);
    }
  }

  void close() {
    if (_bluetoothConnection != null) {
      _bluetoothConnection!.dispose();
    }
  }
}
