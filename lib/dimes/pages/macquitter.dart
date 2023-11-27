import 'dart:ui';

import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:intl/intl.dart';

import 'package:eglise_de_ville/dimes/number_keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:kkiapay_flutter_sdk/kkiapay/view/widget_builder_view.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../contante_var2.dart';
import '../../user_login/authpage.dart';
import '../kkiapay_config.dart';

class PaiementDime extends StatefulWidget {
  @override
  State<PaiementDime> createState() => _PaiementDimeState();
}

class _PaiementDimeState extends State<PaiementDime> {
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
                        "Toutefois, vous pouvez payer plus ou moins que ce montant pour le moment, en modifiant le montant ci-dessous",
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
                    Text("Confirmer vous le paiement de \n" +
                        formatagee(get_dime().toString()) +
                        " F CFA "),
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
                    kkiapay = KKiaPay(
                        callback: successCallback,
                        amount: get_dime(),
                        apikey: kkia_sandox
                            ? kkia_public_key_sandox
                            : kkia_public_key,
                        sandbox: kkia_sandox,
                        data: connected_user.toString(),
                        phone: "",
                        name: camelCase(connected_user["nom"]),
                        theme: "black");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => kkiapay),
                    ).then((value) {
                      exitloading(context);
                    });
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
