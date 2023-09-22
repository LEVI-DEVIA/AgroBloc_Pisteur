import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

import 'Profil.dart';
import 'constante.dart';

class Justifications extends StatefulWidget {
  const Justifications({super.key});

  @override
  State<Justifications> createState() => _JustificationsState();
}

class _JustificationsState extends State<Justifications> {
  List<Contracts> contracts = [];
  Future<void> getContracts() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.137.94:7001/contracts/allfortracker/$trackerId'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          contracts = List<Contracts>.from(
              jsonData.map((data) => Contracts.fromJson(data)));
        });
      } else {
        throw Exception('Erreur de récupération');
      }
    } catch (error) {
      print('Erreur lors de la récupération des produits: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getContracts();
    //getTasks();
  }

  @override
  Widget build(BuildContext context) {
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
          "Justifications",
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profil()),
            );
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: const [
          // Ajoutez ici des actions pour la barre d'applications
        ],
      ),
      body: contracts.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: contracts.length,
              itemBuilder: (context, index) {
                int displayIndex = index + 1;
                /*String formattedTime = DateFormat('HH:mm')
                    .format(DateTime.now());*/ //format de l'heure
                return Card(
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Row(
                      children: [
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Commande pour ${contracts[index].productName} de ${contracts[index].weight} Kg",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Qr Code'),
                            content: Container(
                              width: MediaQuery.of(context).size.width *
                                  0.8, // Définir une largeur appropriée
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  QrImageView(
                                    data: generateQRData(contracts[index]),
                                    version: QrVersions.auto,
                                    size:
                                        150.0, // Ajuster la taille en conséquence
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Fermer'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF40A944),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text('Qr code'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String generateQRData(Contracts contract) {
    // Ici, vous pouvez créer une chaîne contenant les informations du contrat
    // que vous souhaitez afficher dans le code QR. Par exemple :
    String data = 'Nom du produit : ${contract.productName}\n';
    data += 'Poids : ${contract.weight} Kg\n';
    data += 'Montant : ${contract.amount} Fcfa\n';
    data +=
        'Vendeur : ${contract.vendorNames.join(', ')}'; // Affichez tous les noms de vendeurs séparés par des virgules.

    return data;
  }
}

class Contracts {
  final int contractId;
  final int contractDetailId;
  final String productName;
  final String trackerName;
  final double weight;
  final int amount;
  final List<String> vendorNames;

  Contracts({
    required this.contractId,
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
      trackerName: json['trackerName'] as String? ?? '',
      weight: json['weight']?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      vendorNames: vendorNames,
    );
  }
}
