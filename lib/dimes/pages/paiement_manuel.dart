import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:intl/intl.dart';

import 'package:eglise_de_ville/dimes/number_keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/config.dart';

import 'package:overlay_support/overlay_support.dart';

import '../../contante_var2.dart';
import '../../user_login/authpage.dart';

class PaiementManuel extends StatefulWidget {
  @override
  State<PaiementManuel> createState() => _PaiementManuelState();
}

class _PaiementManuelState extends State<PaiementManuel> {
  int _current_menu = 0;
  String saisi = "";
  int montant_recu = 0;
  bool isload = false;
  TextEditingController textEditingController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingController.addListener(() {
      setState(() {
        saisi = textEditingController.text;
      });
    });
    chargement();
  }

  void chargement() async {
    setState(() {
      isload = true;
    });
    var g = await select_local_sqlite(
        "SELECT IFNULL(SUM(Montant), 0) som from Dimes WHERE status='' ", []);
    if (g.isNotEmpty) {
      textEditingController.text =
          int.parse(g.first["som"].toString()).toString();
      setState(() {
        montant_recu = int.parse(g.first["som"].toString());
      });
    }
    setState(() {
      isload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
                exitloading(context);
              },
              icon: Icon(
                CupertinoIcons.xmark_circle_fill,
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
                style: TextStyle(color: textColor(), fontFamily: "Montserrat"),
                children: [
                  TextSpan(
                    text: 'DE ',
                    style: TextStyle(
                      color: Colors.red[200],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: 'VILLE',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]),
          ),
        ),
        body: isload
            ? Center(child: CupertinoActivityIndicator())
            : Container(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                            color: CupertinoColors
                                .activeGreen, //isDark()? Colors.white.withOpacity(.4) : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              isDark()
                                  ? BoxShadow()
                                  : BoxShadow(
                                      color: textColor().withOpacity(.4),
                                      blurRadius: 3)
                            ]),
                        child: ListTile(
                          onLongPress: () {
                            // suppression(index);
                          },
                          trailing: Text(
                            formatagee(montant_recu.toString()) + " F CFA",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Circular",
                                fontSize: 20),
                          ),
                          title: Text(
                            "D'après vos enrégistrements, le montant de votre dîme est : ",
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Text(
                        "Entrez le montant de la dîmes que vous avez payé à l'église",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textColor().withOpacity(.5)),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Flexible(
                        child: Container(
                      height: double.infinity,
                      child: Center(
                        child: true
                            ? TextField(
                                controller: textEditingController,
                                readOnly: true,
                                textAlign: TextAlign.center,
                                style: themeData.textTheme.headline4!.copyWith(
                                  fontSize: 25,
                                  letterSpacing: 2,
                                  color: textColor().withOpacity(.7),
                                ),
                                decoration: InputDecoration(
                                    border: InputBorder.none, hintText: '0'),
                              )
                            : Text(saisi + " F ",
                                style: themeData.textTheme.headline4!
                                    .copyWith(fontSize: 25)),
                      ),
                    )),
                    Container(
                      height: MediaQuery.of(context).size.height * .5,
                      width: double.infinity,
                      child: NumberKeyboard(textEditingController, this),
                    ),
                    SizedBox(
                      height: 5,
                    )
                  ],
                )),
      ),
    );
  }

  int get_dime() {
    double pourcent = 1;

    return (int.tryParse(saisi) ?? 0);
  }

  void save() {
    if (int.tryParse(saisi) == null ||
        int.tryParse(saisi)! <= 0 ||
        get_dime() <= 0) {
      showSimpleNotification(Text("Saisie invalide !"));
    } else {
      if (connected_user.isEmpty) {
        showSimpleNotification(Text("Vous devez d'abord vous authentifier"));
        checkLogin(context).then((value) {
          save();
        });
        // Navigator.push(
        //         context, MaterialPageRoute(builder: (context) => AuthPage()))
        //     .then((value) {});
      } else {
        payer_dime();
      }
    }
  }

  String motif = "";
  void payer_dime() {
    showCupertinoModalPopup(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        context: context,
        builder: (context) {
          return Theme(
            data: themeData,
            child: AlertDialog(
              content: IntrinsicHeight(
                child: Column(
                  children: [
                    Text("Confirmer vous avoir payé  \n" +
                        formatagee(get_dime().toString()) +
                        " F CFA à l'église ?"),
                  ],
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () async {
                    // var list = await select_local_sqlite(
                    //     "SELECT * from Dimes ORDER BY id ASC", []);
                    // print("zopa $list");
                    // return;
                    int montant_paye = get_dime();

                    var list = await select_local_sqlite(
                        "SELECT * from Dimes WHERE status='' ORDER BY id ASC",
                        []);
                    list.forEach((element) async {
                      var id = element["id"];
                      var status = "";
                      var m2 = element["Montant"];

                      if (montant_paye > 0) {
                        montant_paye = montant_paye -
                            int.parse(element["Montant"].toString());
                        if (montant_paye >= 0) {
                          status = "PAYER";
                          await select_local_sqlite(
                              "UPDATE Dimes SET status='PAYER' WHERE id='$id';",
                              []);
                        } else {
                          m2 = montant_paye * -1;
                          await select_local_sqlite(
                              "UPDATE Dimes SET Montant='$m2' WHERE id='$id';",
                              []);
                        }
                      }
                    });
                    exitloading(context);
                    exitloading(context);
                    showSimpleNotification(Text("Enregistrement réussi !"));
                  },
                  child: Text(
                    "Oui",
                    style:
                        (themeData.textTheme.headline2 ?? TextStyle()).copyWith(
                      color: CupertinoColors.activeGreen,
                    ),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    exitloading(context);
                  },
                  child: Text(
                    "Non",
                    style:
                        (themeData.textTheme.headline2 ?? TextStyle()).copyWith(
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
