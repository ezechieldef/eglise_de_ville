import 'dart:ui';

import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_zoom_drawer/config.dart';
import 'package:overlay_support/overlay_support.dart';

class HistoriqueEnregDime extends StatefulWidget {
  HistoriqueEnregDime();

  @override
  State<HistoriqueEnregDime> createState() => _HistoriqueEnregDimeState();
}

class _HistoriqueEnregDimeState extends State<HistoriqueEnregDime> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      chargement();
    });
  }

  bool isload = false;
  List<Map<String, dynamic>> list_dimes = [];
  Future<void> chargement() async {
    setState(() {
      isload = true;
    });
    var t = await select_local_sqlite(
        "SELECT * from Dimes WHERE status='' ORDER BY Date DESC ", []);
    setState(() {
      list_dimes = t;
    });
    setState(() {
      isload = false;
    });
  }

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
                style: TextStyle(
                  color: textColor(),

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
                  )
                ]),
          ),
        ),
        body: isload
            ? Center(child: CupertinoActivityIndicator())
            : list_dimes.isEmpty
                ? Center(child: Text("Aucun enrégistrement disponible"))
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Dîmes ( en attente )",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Flexible(
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: ListView.builder(
                                itemCount: list_dimes.length,
                                itemBuilder: ((context, index) {
                                  return Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 0),
                                      decoration: BoxDecoration(
                                          color: isDark()
                                              ? Colors.white.withOpacity(.4)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          boxShadow: [
                                            isDark()
                                                ? BoxShadow()
                                                : BoxShadow(
                                                    color: textColor()
                                                        .withOpacity(.2),
                                                    blurRadius: 5)
                                          ]),
                                      child: ListTile(
                                          onLongPress: () {
                                            suppression(index);
                                          },
                                          subtitle: Text(
                                            list_dimes[index]["Motif"]
                                                    .toString()
                                                    .isEmpty
                                                ? " ( Sans motif )"
                                                : list_dimes[index]["Motif"]
                                                    .toString(),
                                            style: TextStyle(
                                                color: textColor()
                                                    .withOpacity(.6)),
                                          ),
                                          trailing: Text(
                                            formatagee(list_dimes[index]
                                                        ["Montant"]
                                                    .toString()) +
                                                " F",
                                            style: TextStyle(
                                                fontFamily: 'Circular',
                                                fontWeight: FontWeight.w600),
                                          ),
                                          title: Text(
                                            camelCase(
                                                DateFormat.yMMMMEEEEd("fr")
                                                    .format(DateTime.parse(
                                                        list_dimes[index]
                                                                ["Date"]
                                                            .toString()))),
                                          )));
                                })),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  void suppression(int pos) {
    showCupertinoModalPopup(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        context: context,
        builder: (context) {
          return Theme(
            data: themeData,
            child: AlertDialog(
              content: IntrinsicHeight(
                  child: Column(children: [
                Text(
                    "Confirmer vous la suppression de l'enregistrement : \nMontant : " +
                        formatagee(list_dimes[pos]["Montant"].toString()) +
                        " F CFA " +
                        ", Date : " +
                        camelCase(DateFormat.yMMMMEEEEd("fr").format(
                            DateTime.parse(
                                list_dimes[pos]["Date"].toString()))) +
                        " ?")
              ])),
              actions: [
                MaterialButton(
                  onPressed: () async {
                    await select_local_sqlite(
                        "DELETE FROM Dimes WHERE id='" +
                            list_dimes[pos]["id"].toString() +
                            "'",
                        []);
                    showSimpleNotification(
                        Text("Dîmes supprimée avec succès !"),
                        background: Colors.green);
                    exitloading(context);
                    chargement();
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
