import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'Profil.dart';
import 'constante.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
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

  @override
  void initState() {
    super.initState();
    getContracts();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mes Tâches",
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
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
      ),
      body: contracts.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: contracts.length,
              itemBuilder: (context, index) {
                int displayIndex = index + 1;

                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    setState(() {
                      contracts.removeAt(index);
                    });

                    // Afficher un message de confirmation
                    Fluttertoast.showToast(
                      msg: "Tâche supprimée avec succès",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: Card(
                    elevation: 4.0,
                    margin: EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isExpandedList[index] = !isExpandedList[index];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tâches N°$displayIndex",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                /*Icon(
                                  isExpandedList[index]
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),*/
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Code du contrat : ${contracts[index].contractCode}",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Nom du produit : ${contracts[index].productName}",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Poids : ${contracts[index].weight} Kg",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Coût : ${contracts[index].amount} Fcfa",
                              style: TextStyle(fontSize: 16),
                            ),
                            /*if (isExpandedList[index])
                              Text(
                                "Description détaillée de la tâche...",
                                style: TextStyle(fontSize: 16),
                              ),*/
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class Contracts {
  final int contractId;
  final int contractDetailId;
  final String contractCode;
  final String productName;
  final String trackerName;
  final double weight;
  final int amount;
  final List<String> vendorNames;

  Contracts({
    required this.contractId,
    required this.contractDetailId,
    required this.contractCode,
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
