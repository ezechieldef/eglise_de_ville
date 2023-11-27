import 'dart:ui';

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

class EnregistrerDime extends StatefulWidget {
  @override
  State<EnregistrerDime> createState() => _EnregistrerDimeState();
}

class _EnregistrerDimeState extends State<EnregistrerDime> {
  int _current_menu = 0;
  String saisi = "";
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
        body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CupertinoSlidingSegmentedControl(
                        thumbColor: Colors.white,
                        backgroundColor:
                            themeData.brightness == Brightness.light
                                ? CupertinoColors.tertiarySystemFill
                                : Colors.grey.withOpacity(0.5),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 7),
                        groupValue: _current_menu,
                        onValueChanged: (v) {
                          setState(() {
                            _current_menu = int.parse(v.toString());
                          });
                          // pageController.jumpToPage(_current_menu);
                          // pageController.animateToPage(_current_menu,
                          //     duration: Duration(seconds: 1),
                          //     curve: Curves.decelerate);
                        },
                        children: {
                          0: Text(
                            "Entrée brute",
                            style: TextStyle(
                                color: _current_menu == 0
                                    ? Colors.black
                                    : textColor(),
                                fontWeight: _current_menu == 0
                                    ? FontWeight.w600
                                    : FontWeight.w500),
                          ),
                          1: Text(
                            "Dîme nette ( 10% )",
                            style: TextStyle(
                                color: _current_menu == 1
                                    ? Colors.black
                                    : textColor(),
                                fontWeight: _current_menu == 1
                                    ? FontWeight.w600
                                    : FontWeight.w500),
                          )
                        }),
                  ),
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
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: true
                      ? RichText(
                          textAlign: TextAlign.end,
                          text: TextSpan(
                              text: "Montant Dîme : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: textColor()),
                              children: [
                                TextSpan(
                                    text: formatagee(get_dime()) + ' F CFA',
                                    style: themeData.textTheme.headline4!
                                        .copyWith(
                                            fontSize: 20,
                                            color:
                                                textColor().withOpacity(0.8)))
                              ]))
                      : Text(
                          saisi.isEmpty
                              ? ""
                              : "Montant Dîme : " +
                                  formatagee(get_dime()) +
                                  ' F CFA',
                          textAlign: TextAlign.right,
                          style: themeData.textTheme.headline4!.copyWith()),
                ),
                SizedBox(
                  height: 10,
                ),
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

  String get_dime() {
    double pourcent = 1;
    if (_current_menu == 0) {
      pourcent = 0.1;
    } else {
      pourcent = 1;
    }
    return ((int.tryParse(saisi) ?? 0) * pourcent).round().toString();
  }

  void save() {
    if (int.tryParse(saisi) == null ||
        int.tryParse(saisi)! <= 0 ||
        int.parse(get_dime()) <= 0) {
      showSimpleNotification(Text("Saisie invalide !"));
    } else {
      enregistrer_dime();
    }
  }

  String motif = "";
  void enregistrer_dime() {
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
                    Text("Confirmer vous l'enregistrement de " +
                        formatagee(get_dime()) +
                        " F CFA " +
                        " comme dîme pour le compte de ce jour ( " +
                        camelCase(DateFormat.yMMMMEEEEd("fr")
                            .format(DateTime.now())) +
                        " ) ?"),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        decoration: BoxDecoration(
                          color: textColor().withOpacity(.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          onChanged: (v) {
                            setState(() {
                              motif = v;
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Motif (facultatif)',
                          ),
                        ))
                  ],
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () async {
                    await inserer_local("Dimes", {
                      "Date": DateTime.now().toString(),
                      'Motif': motif,
                      "status": "",
                      "Montant": get_dime()
                    });
                    showSimpleNotification(
                        Text(
                          "Dîmes enrégistré avec succès !",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        position: NotificationPosition.bottom,
                        background: Colors.green);
                    exitloading(context);
                    exitloading(context);
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
