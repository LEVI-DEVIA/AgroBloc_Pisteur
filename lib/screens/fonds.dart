import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:iconsax/iconsax.dart';

import '../screens/connexion/Forgot_Password_Screen.dart';
import 'profil.dart';

void main() {
  runApp(const MaterialApp(
    home: Fonds(),
    debugShowCheckedModeBanner: false,
  ));
}

class Fonds extends StatefulWidget {
  const Fonds({Key? key}) : super(key: key);

  @override
  _FondsState createState() => _FondsState();
}

class _FondsState extends State<Fonds> {
  late ScrollController _scrollController;
  bool _isScrolled = false;

  static const List<dynamic> _services = [
    ['Envoie', Iconsax.send_square4, Colors.pink],
    /*['Bill', Iconsax.wallet_3, Colors.orange],*/
    /*['More', Iconsax.more, Colors.green],*/
  ];

  List<dynamic> _transactions = [
    ['AgroBloc', 'images/pic/logo.png', '07h20min', '\190.000 FCFA'],
    ['AgroBloc', 'images/pic/logo.png', '19h20min', '\200.000 FCFA'],
    ['AgroBloc', 'images/pic/logo.png', '20h30min', '\549.000 FCFA'],
  ];

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_listenToScrollChange);

    super.initState();
  }

  void _listenToScrollChange() {
    if (_scrollController.offset >= 100.0) {
      setState(() {
        _isScrolled = true;
      });
    } else {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  //final _advancedDrawerController = AdvancedDrawerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: CustomScrollView(controller: _scrollController, slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            elevation: 0,
            pinned: true,
            stretch: true,
            toolbarHeight: 80,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profil()),
                ); // Redirige vers la page précédente
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
            ),
            /*IconButton(
                color: Colors.black,
                onPressed: _handleMenuButtonPressed,
                icon: ValueListenableBuilder<AdvancedDrawerValue>(
                  valueListenable: _advancedDrawerController,
                  builder: (_, value, __) {
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 250),
                      child: Icon(
                        value.visible ? Iconsax.close_square : Iconsax.menu,
                        key: ValueKey<bool>(value.visible),
                      ),
                    );
                  },
                ),
              ),*/
            actions: [
              IconButton(
                icon: Icon(Iconsax.logout, color: Colors.grey.shade700),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
              ),
              /*IconButton(
                  icon: Icon(Iconsax.more, color: Colors.grey.shade700),
                  onPressed: () {},
                ),*/
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            centerTitle: true,
            title: AnimatedOpacity(
              opacity: _isScrolled ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  Text(
                    '\ 939.000 FCFA',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 30,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              titlePadding: const EdgeInsets.only(left: 20, right: 20),
              title: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _isScrolled ? 0.0 : 1.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FadeIn(
                      duration: const Duration(milliseconds: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '939.000',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            '\ FCFA',
                            style: TextStyle(
                                color: Colors.grey.shade800, fontSize: 22),
                          ),
                          /*Text(
                              '939.000',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),*/
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    /*FadeIn(
                        duration: const Duration(milliseconds: 500),
                      child: MaterialButton(
                          height: 30,
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          onPressed: () {},
                          child: Text(
                            '',
                          ),
                          color: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),*/
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 30,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              height: 115,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  return FadeInDown(
                    duration: Duration(milliseconds: (index + 1) * 100),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GestureDetector(
                        onTap: () {
                          /*if (_services[index][0] == 'Transfer') { 
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage()));
                              }*/
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Icon(
                                  _services[index][1],
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              _services[index][0],
                              style: TextStyle(
                                  color: Colors.grey.shade800, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ])),
          SliverFillRemaining(
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 30),
              child: Column(
                children: [
                  FadeInDown(
                    duration: Duration(milliseconds: 500),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Aujourd'hui",
                            style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('\ 939.000 FCFA',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              )),
                        ]),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 20),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        return FadeInDown(
                          duration: Duration(milliseconds: 500),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      _transactions[index][1],
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _transactions[index][0],
                                          style: TextStyle(
                                              color: Colors.grey.shade900,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          _transactions[index][2],
                                          style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  _transactions[index][3],
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ]));
  }

  /*void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }*/
}
