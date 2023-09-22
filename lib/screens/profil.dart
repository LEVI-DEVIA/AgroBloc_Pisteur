import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'ble.dart';
import 'bluetooth_page.dart';
import 'connexion/welcome_screen.dart';
import 'constante.dart';
import 'fonds.dart';
import 'justification.dart';
import 'notifications.dart';
import 'package:http/http.dart' as http;

class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  _ProfilState createState() => _ProfilState();
}

class Contracts {
  final int contractId;
  final String contractCode;
  final int contractDetailId;
  final String productName;
  final String trackerName;
  final double weight;
  final int amount;
  final List<String> vendorNames;

  Contracts({
    required this.contractId,
    required this.contractCode,
    required this.contractDetailId,
    required this.productName,
    required this.trackerName,
    required this.weight,
    required this.amount,
    required this.vendorNames,
  });

  factory Contracts.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List;
    List<String> vendorNames =
        detailsList.map((data) => data['vendorName'] as String).toList();
    return Contracts(
      contractId: json['contractId'] as int? ?? 0,
      contractDetailId: json['contractDetailId'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      contractCode: json['contractCode'] as String? ?? '',
      trackerName: json['trackerName'] as String? ?? '',
      weight: json['weight']?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      vendorNames: vendorNames,
    );
  }
}

//Pour les Details du Contracts
class ContractDetails {
  final int articleId;
  final String vendorName;
  final double weight;
  final double price;
  final int amount;

  ContractDetails({
    required this.articleId,
    required this.vendorName,
    required this.weight,
    required this.price,
    required this.amount,
  });

  factory ContractDetails.fromJson(Map<String, dynamic> json) {
    return ContractDetails(
      articleId: json['articleId'] as int? ?? 0,
      vendorName: json['vendorName'] as String? ?? '',
      weight: json['weight']?.toDouble() ?? 0.0,
      price: json['price']?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
    );
  }
}

class _ProfilState extends State<Profil> {
  List<Contracts> contracts = [];
  List<bool> isExpandedList = [];
  Future<void> getContracts() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.137.94:7001/contracts/allfortracker/$trackerId'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          contracts = List<Contracts>.from(
              jsonData.map((data) => Contracts.fromJson(data)));
          isExpandedList = List.generate(contracts.length, (index) => false);
        });
      } else {
        throw Exception('Erreur de récupération');
      }
    } catch (error) {
      print('Erreur lors de la récupération des produits: $error');
    }
  }

  int case2ClickCount = 0;

  void _handleCase2Click() {
    setState(() {
      case2ClickCount++;
    });

    if (case2ClickCount == 2) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Vérification du statut'),
            content: LottieBuilder.asset('images/pic/validatonPP.json'),
            actions: [
              TextButton(
                onPressed: () {
                  Fluttertoast.showToast(
                    msg: 'Félicitation, votre compte à été aprouvé',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                  Navigator.pop(context); // Fermer la boîte de dialogue
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Vérification du statut'),
            content: FractionallySizedBox(
              widthFactor: 0.8, // Ajustez cette valeur selon vos besoins
              heightFactor: 0.5, // Ajustez cette valeur selon vos besoins
              child: LottieBuilder.asset('images/pic/verification.json'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Fluttertoast.showToast(
                    msg:
                        'AgroBloc vérifie votre document, veuillez patienter ☺️',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                  Navigator.pop(context); // Fermer la boîte de dialogue
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _navigateToPage(int index, BuildContext context) {
    final ImageProvider image;
    final String productName;
    final int quantity;
    switch (index) {
      /*case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Fonds()),
        );
        break;*/
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Notifications()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Justifications()),
        );
        break;
      case 2:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return FutureBuilder<void>(
              future: getContracts(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erreur de chargement');
                } else {
                  // Trier les éléments de la liste contracts par contractId
                  contracts
                      .sort((a, b) => a.contractId.compareTo(b.contractId));

                  // Inverser l'ordre pour placer les nouveaux contrats en haut
                  contracts = contracts.reversed.toList();

                  return SimpleDialog(
                    title: Text('Liste des numéros de commande'),
                    children: contracts.map((contract) {
                      return SimpleDialogOption(
                        onPressed: () {
                          // Faites quelque chose avec le code sélectionné
                          // Par exemple, afficher le contractCode
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BluetoothPage(
                                contractCode: contract.contractCode,
                                contractID: contract.contractId,
                              ),
                            ),
                          );
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Contract Code'),
                                content: Text(contract.contractCode),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Fermer'),
                                  ),
                                ],
                              );
                            },
                          );
                          Navigator.pop(context); // Ferme le premier popup
                        },
                        child: Text(contract.contractCode),
                      );
                    }).toList(),
                  );
                }
              },
            );
          },
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
        break;
      // Ajoutez des cas supplémentaires pour chaque index correspondant à une page différente
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    // _showToastWithDelay();
  }

  void _showToastWithDelay() async {
    await Future.delayed(const Duration(seconds: 30));
    Fluttertoast.showToast(
      msg: 'Votre document à été approuvé, vous pouvez donc vendre 😉',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  bool isButtonSelected = false;
  int currentPageIndex = 2;
  List<ProfileCompletionCard> profileCompletionCards = [
    ProfileCompletionCard(
      title: "Charger votre attestation",
      icon: CupertinoIcons.doc,
      buttonText: "Upload",
    ),
  ];

  List<CustomListTile> customListTiles = [
    /*CustomListTile(
      icon: Icons.insights,
      title: "Fonds",
    ),*/
    /*CustomListTile(
      icon: Icons.location_on_outlined,
      title: "Location",
    ),*/
    CustomListTile(
      title: "Tâches",
      icon: CupertinoIcons.bell,
    ),
    CustomListTile(
      title: "Justifications",
      icon: CupertinoIcons.checkmark_shield,
    ),
    CustomListTile(
      title: "Vérifications",
      icon: CupertinoIcons.bars,
    ),
    CustomListTile(
      title: "Se déconnecter",
      icon: CupertinoIcons.arrow_right_arrow_left,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          "Profile",
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: const [
          /*IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_rounded),
          )*/
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("images/imges/img.jpeg"),
              ),
              SizedBox(height: 10),
              Text(
                trackerName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Pisteur")
            ],
          ),
          const SizedBox(height: 40),
          ...List.generate(
            customListTiles.length,
            (index) {
              final tile = customListTiles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  child: ListTile(
                    leading: Icon(tile.icon),
                    title: Text(tile.title),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _navigateToPage(index,
                          context); // Appeler une fonction pour la navigation avec l'index correspondant
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfileCompletionCard {
  final String title;
  final String buttonText;
  final IconData icon;
  ProfileCompletionCard({
    required this.title,
    required this.buttonText,
    required this.icon,
  });
}

class CustomListTile {
  final IconData icon;
  final String title;
  CustomListTile({
    required this.icon,
    required this.title,
  });
}
