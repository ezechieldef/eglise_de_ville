import 'dart:ui';

import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_zoom_drawer/config.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../api_operation.dart';
import '../../user_login/authpage.dart';

class HistoriquePaiement extends StatefulWidget {
  @override
  State<HistoriquePaiement> createState() => _HistoriquePaiementState();
}

class _HistoriquePaiementState extends State<HistoriquePaiement> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      chargement();
    });
  }

  bool isload = false;
  List<Map<String, dynamic>> list_paiement = [];
  Future<void> chargement() async {
    if (connected_user.isEmpty) {
      showSimpleNotification(Text("Vous devez d'abord vous authentifier"));

      Navigator.push(
              context, MaterialPageRoute(builder: (context) => AuthPage()))
          .then((value) {});
      return;
    }
    setState(() {
      isload = true;
      list_paiement = [];
    });

    var t = await select_data(
        "SELECT * from Dimes WHERE user_id='${connected_user["id"]}' ORDER BY id DESC");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_paiement = t;
      });
      inserer_local_list("dimes_payer", t);
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      //showMessage("Erreur", t[0]["error"].toString(), context);
      showMessage("Avertissement", internet_off_str, context);
      try {
        var t2 = await select_local_sqlite(
            "SELECT * from dimes_payer WHERE user_id='${connected_user["id"]}' ORDER BY id DESC",
            []);
        setState(() {
          list_paiement = t2;
        });
      } catch (e) {}
    }

    setState(() {
      isload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: RefreshIndicator(
        onRefresh: chargement,
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
              : list_paiement.isEmpty
                  ? InkWell(
                      onTap: chargement,
                      child: Center(
                          child: Text(
                        "Aucun enrégistrement disponible\n\nCliquez pour actualiser",
                        textAlign: TextAlign.center,
                      )))
                  : Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      CupertinoColors.activeGreen,
                                      Colors.green[700]!
                                    ])),
                            child: Center(
                              child: Text(
                                "Historique de vos paiements via l'application",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 18),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Flexible(
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: list_paiement.length,
                                  itemBuilder: ((context, index) {
                                    return Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 0),
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
                                            subtitle: Text(
                                              "ID Transaction : " +
                                                  list_paiement[index]
                                                          ["id_transaction"]
                                                      .toString(),
                                              style: TextStyle(
                                                  color: textColor()
                                                      .withOpacity(.6)),
                                            ),
                                            trailing: Text(
                                              formatagee(list_paiement[index]
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
                                                          list_paiement[index]
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
                        formatagee(list_paiement[pos]["Montant"].toString()) +
                        " F CFA " +
                        ", Date : " +
                        camelCase(DateFormat.yMMMMEEEEd("fr").format(
                            DateTime.parse(
                                list_paiement[pos]["Date"].toString()))) +
                        " ?")
              ])),
              actions: [
                MaterialButton(
                  onPressed: () async {
                    await select_local_sqlite(
                        "DELETE FROM Dimes WHERE id='" +
                            list_paiement[pos]["id"].toString() +
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
