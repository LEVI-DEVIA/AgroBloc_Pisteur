import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:appmobile_agrobloc/screens/weight_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
//import 'weight_service.txt';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_math_fork/flutter_math.dart' as math;
import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:http/http.dart' as http;

import 'Profil.dart';

class BluetoothPage extends StatefulWidget {
  final String contractCode;
  final int contractID;
  const BluetoothPage(
      {super.key, required this.contractCode, required this.contractID});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  Future updateStatus() async {
    var url =
        "http://192.168.137.94:7001/contracts/update-status/completed/${widget.contractID}";
    var response = await http.get(Uri.parse(url));
    print(json.decode(response.body));
    return json.decode(response.body);
  }

  late String enabled;
  //late Future<bool> isEnabled;
  late BluetoothState _bluetoothState = BluetoothState.STATE_OFF;
  late Stream bluetoothScan;
  late bool _apairing = false;
  late bool _searching = false;
  late String _deviceAddressMac;
  String poids = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //devices = getDevices();
    _deviceAddressMac = '';

    startScan();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /*startScan() {
    if (isDiscovering) return; // Vérifiez si une recherche est déjà en cours

    FlutterBluetoothSerial.instance.cancelDiscovery();
    setState(() {
      devices.clear();
    });

    setState(() {
      isDiscovering = true; // Marquez la recherche en cours
    });
    FlutterBluetoothSerial.instance.startDiscovery().listen((Sdevice) {
      var device = Sdevice.device;
      // Vérifier si l'appareil n'est pas déjà apparié

      if (device.name != null) {
        if (device.name!.contains("BLE232")) {
          // verifier si la liste ne contient pas déja cet bluetooth
          if (!devices.contains(device)) {
            setState(() {
              devices.add(device);
              print(
                  'Nouvel appareil découvert : ${device.name}, Adresse : ${device.address}');
            });
          }
        }
      }
    }).onDone(() {
      setState(() {
        isDiscovering =
            false; // Réinitialisez la variable après la fin de la recherche
      });
    });
  }*/

  startScan() {
    if (isDiscovering) return; // Vérifiez si une recherche est déjà en cours

    WeightService.getFlutterBluetoothSerial().cancelDiscovery();
    setState(() {
      devices.clear();
    });

    setState(() {
      isDiscovering = true; // Marquez la recherche en cours
    });
    WeightService.getFlutterBluetoothSerial()
        .startDiscovery()
        .listen((Sdevice) {
      var device = Sdevice.device;
      // Vérifier si l'appareil n'est pas déjà apparié

      if (device.name != null) {
        //device.name!.contains("BLE232")
        if (device.name!.contains("BLE232")) {
          // verifier si la liste ne contient pas déja cet bluetooth
          if (!devices.contains(device)) {
            setState(() {
              devices.add(device);
              print(
                  'Nouvel appareil découvert : ${device.name}, Adresse : ${device.address}');
            });
          }
        }
      }
    }).onDone(() {
      setState(() {
        isDiscovering =
            false; // Réinitialisez la variable après la fin de la recherche
      });
    });
  }

  List<BluetoothDevice> devices = [];

  bool isDiscovering = false; // Ajoutez cette variable dans votre classe

  getActionButton() {
    var result = [
      IconButton(onPressed: startScan, icon: Icon(Icons.refresh_rounded)),
    ];
    if (WeightService.bluetoothIsConnected()) {
      result.insert(
          0,
          IconButton(
              onPressed: () {
                WeightService.openReception();
              },
              icon: const Icon(Icons.open_in_new)));
      result.insert(
          0,
          IconButton(
              onPressed: () {
                WeightService.closeReception();
              },
              icon: const Icon(Icons.close)));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    //getIsEnabled();
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white.withAlpha(200),
        foregroundColor: Colors.black,
        title: Text(
          "Module BLE 232",
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        actions: getActionButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              math.Math.tex(
                'Poids: ${poids.isNotEmpty ? poids : '0'} \\, \\text{kg}', // Utilisation de LaTeX pour le formatage
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //Text(poids),
              !WeightService.bluetoothIsEnabled()
                  ? Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.bluetooth_disabled,
                            size: 200,
                            color: Colors.grey,
                          ),
                          Text(
                            "Activez le bluetooth pour trouver des appareils BLE232 à proximité",
                            textAlign: TextAlign.center,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              bool? r = await FlutterBluetoothSerial.instance
                                  .requestEnable();

                              if (r == true)
                                startScan();
                              else
                                print("Erreur lors de la recherche bluetooth");
                            },
                            child: Text("Activer le Bluetooth"),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        isDiscovering
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Text(""),
                        (!isDiscovering && devices.length <= 0)
                            ? Center(
                                child: Text("Aucun appareil trouvé"),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  updateStatus();
                                  Fluttertoast.showToast(
                                    msg: 'Produit Récuperer',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Profil()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFF40A944),
                                ),
                                child: Text('Recupération du produit'),
                              ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height - 200,
                            child: ListView.builder(
                                itemCount: devices.length,
                                itemBuilder: (builder, index) => Container(
                                      margin: EdgeInsets.all(10),
                                      child: ListTile(
                                        title: Text(
                                            devices[index].name.toString(),
                                            style: TextStyle(fontSize: 20)),
                                        subtitle: Text(devices[index]
                                            .name!
                                            .split(' ')
                                            .first),
                                        onTap: () => AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.noHeader,
                                          dismissOnBackKeyPress: false,
                                          body: Column(
                                            children: [
                                              Center(
                                                  child: Text(
                                                "Voulez-vous ajouter l'appareil",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              )),
                                              Column(
                                                children: [
                                                  Center(
                                                      child: Text(
                                                    devices[index]
                                                        .name
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                                  _apairing
                                                      ? Center(
                                                          child:
                                                              CircularProgressIndicator())
                                                      : Text("")
                                                ],
                                              ),
                                            ],
                                          ),
                                          btnCancelOnPress: () {
                                            setState(() {
                                              _apairing = false;
                                            });
                                          },
                                          btnOkOnPress: () async {
                                            setState(() {
                                              _apairing = true;
                                            });
                                            WeightService.connect(
                                                    devices[index].address)
                                                .then((bConnection) {
                                              if (bConnection.isConnected) {
                                                debugPrint(
                                                    "Connecter à ${devices[index].name}");
                                                /*Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (builder) =>
                                                            ));*/

                                                setState(() {
                                                  WeightService.getInput()!
                                                      .listen((data) {
                                                    String decode =
                                                        ascii.decode(data);
                                                    debugPrint(decode);
                                                    setState(() {
                                                      poids = decode
                                                          .replaceAll("kg", "")
                                                          .trim();
                                                    });
                                                  });
                                                });
                                              } else {
                                                setState(() {
                                                  _apairing = false;
                                                });
                                                debugPrint(
                                                    "Impossible de se connecter à l'appareil");
                                              }
                                            });
                                          },
                                        )..show(),
                                        onLongPress: () => AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType.noHeader,
                                                title: "Ampoule",
                                                desc:
                                                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                                            .show(),
                                      ),
                                    ))),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
