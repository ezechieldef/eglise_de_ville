import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/dimes/pages/enregistrer_dimes.dart';
import 'package:eglise_de_ville/dimes/pages/historique_enreg.dart';
import 'package:eglise_de_ville/dimes/pages/historiquepaiement.dart';
import 'package:eglise_de_ville/dimes/pages/macquitter.dart';
import 'package:eglise_de_ville/dimes/pages/paiement_manuel.dart';
import 'package:eglise_de_ville/profile_view.dart';
import 'package:eglise_de_ville/user_login/authpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:overlay_support/overlay_support.dart';

import '../contante_var2.dart';
import '../sqlite_folder/principal.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class DimesHome extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  DimesHome(this.zoomDrawerController);

  @override
  State<DimesHome> createState() => _DimesHomeState();
}

class _DimesHomeState extends State<DimesHome> with WidgetsBindingObserver {
  List<Map<String, dynamic>> list_menu = [
    {
      "Titre": "Enregistrer ma dîme",
      "icon": FontAwesomeIcons.calendarDay,
      "page": EnregistrerDime(),
      "color": Colors.green
    },
    {
      "Titre": "Dîme dûe ( Historique )",
      "icon": FontAwesomeIcons.barsStaggered,
      "page": HistoriqueEnregDime(),
      'color': Colors.deepOrange
    },
    {
      "Titre": "Donner ma dîme",
      "icon": FontAwesomeIcons.solidCreditCard,
      "page": PaiementDime(),
      "color": Colors.blue
    },
    // {
    //   "Titre": "Historique de mes paiements",
    //   "icon": FontAwesomeIcons.receipt,
    //   "page": HistoriquePaiement(),
    //   "color": Colors.pink
    // },
    {
      "Titre": "Enregistrer Paiement Manuel\n( à l'église )",
      "icon": FontAwesomeIcons.receipt,
      "page": PaiementManuel(),
      "color": Colors.pink
    },
  ];
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        onPaused();
        break;
      case AppLifecycleState.paused:
        onInactive();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
    }
  }

  void onResumed() {
    print("resume");
  }

  void onPaused() {
    print("pause");
  }

  void onInactive() {
    print("inactive");
  }

  void onDetached() {
    print("detached");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   if (connected_user.isEmpty) {
    //     showSimpleNotification(Text("Vous devez d'abord vous authentifier"));
    //     Navigator.push(context, routeTransition(AuthPage())).then((value) {
    //       print("le retour $connected_user");
    //       if (connected_user.isEmpty) {
    //         print("rien _encore");
    //         showSimpleNotification(
    //             Text("Vous devez d'abord vous authentifier"));

    //         exitloading(context);
    //       } else {
    //         if (mounted)
    //           setState(() {
    //             connected_user = connected_user;
    //           });
    //       }
    //     });
    //   }
    // });
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {
                widget.zoomDrawerController.toggle!();
              },
              icon: Icon(
                Icons.menu,
                color: Colors.red,
              )),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  themeData = isDark() ? themeDatalight : themeDatadark;
                });
              },
              icon: Icon(
                isDark()
                    ? CupertinoIcons.sun_max_fill
                    : CupertinoIcons.moon_stars_fill,
              ),
            ),
          ],
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: 'EGLISE ',
                style: TextStyle(color: textColor(), fontFamily: "Montserrat"
                    // color: Colors.black,
                    // fontSize: 14,
                    ),
                children: [
                  TextSpan(
                    text: 'DE ',
                    style: TextStyle(
                      color: Colors.red[200],
                      // color: Colors.black,
                      fontWeight: FontWeight.w600,
                      // fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: 'VILLE',
                    style: TextStyle(
                      color: Colors.red,
                      // color: Colors.black,
                      fontWeight: FontWeight.w600,
                      // fontSize: 14,
                    ),
                  ),
                  // TextSpan(
                  //   text: ' : Bible',
                  //   style: TextStyle(
                  //     color: Colors.black54,
                  //     // color: Colors.black,
                  //     fontWeight: FontWeight.w500,
                  //     // fontSize: 14,
                  //   ),
                  // )
                ]),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xfff78ca0),
                            Color(0xfff9748f),
                            Color(0xfffd868c),
                            Color(0xfffe9a8b)
                          ])),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Center(
                          child: Text(
                            // "2 Corin 9: 6-11, 1 Corin 16:2",
                            "2 Corinthiens 9:7 Que chacun donne comme il l'a résolu en son coeur, sans tristesse ni contrainte; car Dieu aime celui qui donne avec joie. 8 Et Dieu peut vous combler de toutes sortes de grâces, afin que, possédant toujours en toutes choses de quoi satisfaire à tous vos besoins, vous ayez encore en abondance pour toute bonne oeuvre",
                            style: TextStyle(
                              // fontSize: 17,
                              color: Colors.white,
                              height: 1.6,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        InkWell(
                          onTap: () {
                            try {
                              ul.launchUrl(Uri.parse("+22967659797"));
                            } catch (e) {
                              print("ca va pas ");
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black38, blurRadius: 3)
                                ],
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(
                              "(+ 229)67 65 97 97",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Dîmes",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  width: double.infinity,
                  child: ListView.separated(
                      shrinkWrap: true,
                      controller: scrollController,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            if (list_menu[index]["page"] != null) {
                              Navigator.push(context,
                                  routeTransition(list_menu[index]["page"]));
                            }
                          },
                          minVerticalPadding: 0,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            list_menu[index]["icon"],
                            color: list_menu[index]["color"],
                          ),
                          title: Text(list_menu[index]["Titre"].toString()),
                          trailing: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.arrow_right,
                              )),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 1,
                        );
                      },
                      itemCount: list_menu.length),
                ),
                ProfileView()
              ],
            ),
          ),
        ),
      ),
    );
  }

  void deconnec() {
    showDialog(
        context: context,
        builder: (context) => Theme(
              data: themeData,
              child: AlertDialog(
                content: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nom : ' + (connected_user["nom"] ?? ''),
                        // style: Theme.of(context).textTheme.bodyText1,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Email : ' + (connected_user["email"] ?? ''),
                        // style: Theme.of(context).textTheme.bodyText1,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      MaterialButton(
                        onPressed: () async {
                          await select_local_sqlite(
                              "DELETE FROM users WHERE 1", []);
                          setState(() {
                            connected_user = {};
                          });
                          exitloading(context);
                        },
                        minWidth: double.infinity,
                        textColor: Colors.white,
                        color: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text("Se déconnecter"),
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
}
