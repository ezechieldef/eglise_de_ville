import 'dart:io';
import 'dart:ui';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:html_editor/html_editor.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../contantes.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

class ReadCharpenterBible extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  ReadCharpenterBible(this.map_data);

  @override
  State<ReadCharpenterBible> createState() =>
      _ReadCharpenterBibleState(this.map_data);
}

class _ReadCharpenterBibleState extends State<ReadCharpenterBible> {
  bool isload = false;
  Map<String, dynamic> map_data;
  _ReadCharpenterBibleState(this.map_data);
  List<Map<String, dynamic>> list_verset = [];
  Map<int, Map<String, dynamic>> list_Customisation = {};
  Map<String, Color> surligneCoulors = {
    "yellow": Colors.yellow.withOpacity(.8),
    "cyan": Colors.cyan.withOpacity(.8),
    "pink": Colors.pinkAccent.withOpacity(.8),
    "green": CupertinoColors.activeGreen.withOpacity(.8),
    "orange": CupertinoColors.activeOrange.withOpacity(.8),
    "purple": CupertinoColors.systemPurple.withOpacity(.8)
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    charger_verset();
  }

  charger_customisation() async {
    await preparerCustomisation();
    var pref = await select_local_sqlite_bible(
        "SELECT * FROM Customisation WHERE Livre = ? AND Chapitre = ? ",
        [map_data['Livre'], map_data['Chapitre']]);
    setState(() {
      list_Customisation = {};
    });
    pref.forEach((element) {
      if (!list_Customisation.containsKey(element['Verset'])) {
        list_Customisation[element['Verset']] = {};
      }
      setState(() {
        list_Customisation[element['Verset']]![element['Cle']] =
            element['Valeur'];
      });
    });
    print("Preference $list_Customisation");
  }

  dynamic? getCustomisation(int verset, String cle) {
    if (!list_Customisation.containsKey(verset)) {
      return null;
    }
    if (!list_Customisation[verset]!.containsKey(cle)) {
      return null;
    }
    return list_Customisation[verset]![cle];
  }

  void charger_verset() async {
    setState(() {
      isload = true;
    });
    await charger_customisation();
    print("gazo $map_data");

    var t = await select_local_sqlite_bible(
        "SELECT * from " +
            map_data["Table"] +
            " WHERE Livre=? AND Chapitre=? ORDER BY Verset ASC",
        [map_data["Livre"], map_data["Chapitre"]]);
    setState(() {
      list_verset = dupliquer(t);
    });

    setState(() {
      isload = false;
    });
  }

  void btn_next() async {
    if (map_data["Chapitre"] < map_data["MaxChapitre"]) {
      setState(() {
        map_data.update("Chapitre", (value) => value + 1);
      });
      charger_verset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Vous êtes déjà au dernier chapitre de " +
              map_data["LibLivre"])));
    }
  }

  void btn_previous() async {
    if (map_data["Chapitre"] > 1) {
      setState(() {
        map_data.update("Chapitre", (value) => value - 1);
      });
      charger_verset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Vous êtes déjà au premier chapitre de " +
              map_data["LibLivre"])));
    }
  }

  Future<void> souligner(index) async {
    if (getCustomisation(index, "Souligner") != null) {
      await select_local_sqlite_bible(
          "DELETE FROM Customisation WHERE Livre=? AND Chapitre=? AND Verset=? AND Cle=?",
          [map_data['Livre'], map_data['Chapitre'], index, 'Souligner']);
    } else {
      await select_local_sqlite_bible(
          "REPLACE INTO Customisation(Livre, Chapitre,Verset,Cle,Valeur) VALUES (?,?,?,'Souligner',?)",
          [map_data['Livre'], map_data['Chapitre'], index, 'true']);
    }
    await charger_customisation();
  }

  Future<void> favoriser(index) async {
    if (getCustomisation(index, "Souligner") != null) {
      await select_local_sqlite_bible(
          "DELETE FROM Customisation WHERE Livre=? AND Chapitre=? AND Verset=? AND Cle=?",
          [map_data['Livre'], map_data['Chapitre'], index, 'Favoris']);
    } else {
      await select_local_sqlite_bible(
          "REPLACE INTO Customisation(Livre, Chapitre,Verset,Cle,Valeur) VALUES (?,?,?,'Favoris',?)",
          [map_data['Livre'], map_data['Chapitre'], index, 'true']);
    }

    await charger_customisation();
  }

  Future<void> coloriser(int index, String couleur) async {
    if (getCustomisation(index, "Couleur").toString() == couleur) {
      await select_local_sqlite_bible(
          "DELETE FROM Customisation WHERE Livre=? AND Chapitre=? AND Verset=? AND Cle=?",
          [map_data['Livre'], map_data['Chapitre'], index, 'Couleur']);
    } else {
      await select_local_sqlite_bible(
          "REPLACE INTO Customisation(Livre, Chapitre,Verset,Cle,Valeur) VALUES (?,?,?,'Couleur',?)",
          [map_data['Livre'], map_data['Chapitre'], index, couleur]);
    }

    await charger_customisation();
  }

  Future<void> ajouter_note(int index, String notes) async {
    var t = await select_local_sqlite_bible(
        "REPLACE INTO Customisation(Livre, Chapitre,Verset,Cle,Valeur) VALUES (?,?,?,'Notes',?)",
        [map_data['Livre'], map_data['Chapitre'], index, notes]);
    await charger_customisation();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: isDark() ? Colors.black : Color(0xfffafafa),
          appBar: AppBar(
            centerTitle: true,
            elevation: 1,
            backgroundColor: isDark() ? Colors.black : Color(0xfffafafa),
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
                  color: themeData.iconTheme.color!.withOpacity(.7),
                ),
              )
            ],
            leading: IconButton(
                onPressed: () {
                  exitloading(context);
                },
                icon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: CupertinoColors.activeGreen,
                )),
            title: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: map_data["LibLivre"].toString() +
                      " " +
                      map_data["Chapitre"].toString() +
                      " : ",
                  style: TextStyle(color: textColor(), fontFamily: "Montserrat"
                      // color: Colors.black,
                      // fontSize: 14,
                      ),
                  children: [
                    TextSpan(
                      text: map_data["Version"].toString(),
                      style: TextStyle(
                        color: Colors.red[400],
                        // color: Colors.black,
                        fontWeight: FontWeight.w600,
                        // fontSize: 14,
                      ),
                    ),
                  ]),
            ),
            // actions: [
            //   IconButton(
            //       onPressed: () {},
            //       icon: Icon(
            //         CupertinoIcons.arrowtriangle_right_circle_fill,
            //         color: Colors.grey[600],
            //       ))
            // ],
          ),
          body: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 5),
              // color: Colors.yellow,
              child: isload
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : GestureDetector(
                      // onHorizontalDragUpdate: (details) {
                      //   // Note: Sensitivity is integer used when you don't want to mess up vertical drag
                      //   int sensitivity =
                      //       (MediaQuery.of(context).size.width / 20).toInt();
                      //   if (details.delta.dx > sensitivity) {
                      //     print("zizi previous");
                      //     btn_previous();
                      //   } else if (details.delta.dx < -sensitivity) {
                      //     //Left Swipe
                      //     print("zizi next");
                      //     btn_next();
                      //   }
                      // },
                      onHorizontalDragEnd: (DragEndDetails details) {
                        if (details.primaryVelocity! > 0) {
                          // User swiped Left
                          btn_previous();
                        } else if (details.primaryVelocity! < 0) {
                          // User swiped Right

                          btn_next();
                        }
                      },
                      child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return Divider(
                              indent: 10,
                              endIndent: 10,
                              // color: Colors.grey[200],
                            );
                          },
                          itemCount: list_verset.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: map_data["Verset"] ==
                                      list_verset[index]["Verset"]
                                  ? Colors.red.withOpacity(.1)
                                  : null,
                              child: InkWell(
                                // onTap: () {
                                //   for (var i = 0; i < list_verset.length; i++) {
                                //     setState(() {
                                //       list_verset[i].remove("Click");
                                //     });
                                //   }
                                //   setState(() {
                                //     list_verset[index]
                                //         .putIfAbsent("Click", () => "");
                                //   });
                                // },
                                onLongPress: () {
                                  bottomsheet(index);
                                },
                                onDoubleTap: () {
                                  bottomsheet(index);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 0),
                                  child: RichText(
                                      text: TextSpan(
                                          text: list_verset[index]["Verset"]
                                                  .toString() +
                                              "  ",
                                          style: TextStyle(
                                              color:
                                                  CupertinoColors.activeGreen,
                                              fontSize: 17,
                                              fontFamily: "Circular",
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w600),
                                          children: [
                                        TextSpan(
                                          text: list_verset[index]["Contenu"]
                                              .toString(),
                                          style: TextStyle(
                                              color: textColor(),
                                              backgroundColor: surligneCoulors[
                                                      getCustomisation(
                                                          list_verset[index]
                                                              ["Verset"],
                                                          "Couleur")] ??
                                                  Colors.transparent,
                                              decoration: getCustomisation(
                                                              list_verset[index]
                                                                  ["Verset"],
                                                              "Souligner")
                                                          .toString() ==
                                                      "true"
                                                  ? TextDecoration.underline
                                                  : TextDecoration.none,
                                              fontSize: 15,
                                              fontFamily: "SourceSansPro",
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        TextSpan(
                                            text: (getCustomisation(
                                                            list_verset[index]
                                                                ["Verset"],
                                                            "Favoris")
                                                        .toString() ==
                                                    "true"
                                                ? "   ❤"
                                                : ""))
                                      ])),
                                ),
                              ),
                            );
                          }),
                    ))),
    );
  }

  Widget get_col_textfield(String titre, {int mini = 1, int maxi = 1}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre),
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4)),
            child: TextFormField(
              initialValue: map_data[titre].toString(),
              onChanged: (v) {
                setState(() {
                  map_data.update(titre, (value) => v);
                });
              },
              minLines: mini,
              maxLines: maxi,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          )
        ],
      ),
    );
  }

  void bottomsheet(int index) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(
              right: 20,
              left: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
                color: isDark() ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      height: 4,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(7)),
                    ),
                  ),
                  Text(
                    map_data["LibLivre"].toString() +
                        " " +
                        map_data["Chapitre"].toString() +
                        " : " +
                        (index + 1).toString() +
                        " -- " +
                        map_data["Version"].toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2 / 1.3,
                    children: [
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                              text: map_data["LibLivre"].toString() +
                                  " " +
                                  map_data["Chapitre"].toString() +
                                  " v " +
                                  (index + 1).toString() +
                                  " : " +
                                  map_data["Version"].toString() +
                                  "\n" +
                                  list_verset[index]["Contenu"].toString()));
                          showSimpleNotification(
                              Text("Verset Copié dans le Press-Papier"),
                              background: CupertinoColors.activeGreen);
                          Navigator.pop(context);
                        },
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.copy,
                              ),
                              Text(
                                "Copier",
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: isDark()
                                  ? Colors.white.withOpacity(.2)
                                  : CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(7)),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await souligner(list_verset[index]["Verset"]);
                          Navigator.pop(context);
                        },
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.format_underline_rounded,
                              ),
                              Text("Souligner", style: TextStyle(fontSize: 12))
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: getCustomisation(
                                              list_verset[index]["Verset"],
                                              "Souligner")
                                          .toString() ==
                                      "true"
                                  ? CupertinoColors.activeGreen
                                  : isDark()
                                      ? Colors.white.withOpacity(.2)
                                      : CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(7)),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await favoriser(list_verset[index]["Verset"]);
                          Navigator.pop(context);
                        },
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                              ),
                              Text("Sauvegarder",
                                  style: TextStyle(fontSize: 12))
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: (getCustomisation(
                                              list_verset[index]["Verset"],
                                              "Favoris")
                                          .toString() ==
                                      "true"
                                  ? CupertinoColors.activeGreen
                                  : (isDark()
                                      ? Colors.white.withOpacity(.2)
                                      : CupertinoColors.systemGrey6)),
                              borderRadius: BorderRadius.circular(7)),
                        ),
                      )
                    ],
                  ),
                  // Text("Surligner"),
                  IntrinsicHeight(
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (var color in surligneCoulors.entries)
                            InkWell(
                              onTap: () async {
                                await coloriser(
                                    list_verset[index]["Verset"], color.key);
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    border: getCustomisation(
                                                list_verset[index]["Verset"],
                                                "Couleur") ==
                                            color.key
                                        ? Border.all(
                                            width: 3,
                                            color: textColor().withOpacity(.5))
                                        : Border.all(
                                            width: 0,
                                            color: Colors.transparent),
                                    shape: BoxShape.circle,
                                    color: color.value.withOpacity(.8)),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  Theme(
                    data: ThemeData(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        "Comparaison",
                        style: TextStyle(
                            color: textColor(),
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                      childrenPadding: EdgeInsets.zero,
                      children: [
                        BottomComparaison(
                            list_verset[index]["Verset"], map_data),
                        SizedBox(
                          height: 15,
                        )
                      ],
                    ),
                  ),

                  Theme(
                    data: ThemeData(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        "Note",
                        style: TextStyle(
                            color: textColor(),
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                      childrenPadding: EdgeInsets.zero,
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: isDark()
                                    ? Colors.white.withOpacity(.2)
                                    : CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(7)),
                            child: TextFormField(
                              minLines: 5,
                              maxLines: 20,
                              initialValue: getCustomisation(
                                      list_verset[index]["Verset"], "Notes") ??
                                  "",
                              onChanged: (v) async {
                                ajouter_note(
                                    list_verset[index]["Verset"], v.toString());
                              },
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                            )),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class BottomComparaison extends StatefulWidget {
  int verset;
  Map<String, dynamic> map_data;
  BottomComparaison(this.verset, this.map_data);

  @override
  State<BottomComparaison> createState() =>
      _BottomComparaisonState(map_data, verset);
}

class _BottomComparaisonState extends State<BottomComparaison> {
  int verset;
  Map<String, dynamic> map_data;
  _BottomComparaisonState(this.map_data, this.verset);
  var listeCompa = {};

  void get_comparaison() async {
    print("grecu verset $verset");
    var editions = await select_local_sqlite_bible(
        "SELECT * from Bibles ORDER BY ID ASC", []);

    editions.forEach((element) async {
      //sleep(Duration(seconds: 2));
      print("elem $element");
      var t = await select_local_sqlite_bible(
          "SELECT * from " +
              element["Table_Name"] +
              " WHERE Livre=? AND Chapitre=? AND Verset=? ORDER BY Verset ASC",
          [map_data["Livre"], map_data["Chapitre"], verset]);
      setState(() {
        listeCompa[element["Version"]] = t;
        print("grecu $t");
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_comparaison();
  }

  @override
  Widget build(BuildContext context) {
    return listeCompa.isEmpty
        ? Center(
            child: CupertinoActivityIndicator(),
          )
        : Column(
            children: [
              for (var item in listeCompa.entries)
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 0),
                //   child: RichText(
                //     text: TextSpan(
                //         text: item.key.toString() + "\n",
                //         style: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             color: textColor(),
                //             height: 3),
                //         children: [
                //           TextSpan(
                //               text: item.value.first['Contenu'].toString(),
                //               style: TextStyle(
                //                   fontWeight: FontWeight.normal, height: 1.2))
                //         ]),
                //   ),
                // )
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                      color: isDark()
                          ? Colors.white.withOpacity(0.2)
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 13),
                    title: SelectableText(
                      item.value.first['Contenu'].toString(),
                      style: TextStyle(color: textColor().withOpacity(.8)),
                    ),
                    subtitle: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        item.key,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: textColor()),
                      ),
                    ),
                  ),
                )
            ],
          );
  }
}
