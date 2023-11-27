import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:eglise_de_ville/admin/admin_ecole/add_chapitre.dart';
import 'package:eglise_de_ville/admin/admin_ecole/list_compo.dart';
import 'package:eglise_de_ville/admin/admin_ecole/quiz.dart';
import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:html_editor/html_editor.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../contantes.dart';
import 'package:intl/intl.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

class AdminChapitres extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  AdminChapitres(Map<String, dynamic> k) {
    map_data = k;
  }

  @override
  State<AdminChapitres> createState() => _AdminChapitresState(this.map_data);
}

class _AdminChapitresState extends State<AdminChapitres> {
  bool isload = false;
  Map<String, dynamic> map_data;

  _AdminChapitresState(this.map_data) {}

  List<Map<String, dynamic>> list_chapitres = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargement();
  }

  void chargement() async {
    setState(() {
      isload = true;
      list_chapitres = [];
    });
    var t = await select_data(
        'SELECT C.* , (select id from Quiz where id_chapitre=C.id Limit 1) quiz from Chapitres C WHERE id_cours=\'' +
            map_data["id"].toString() +
            '\' ORDER BY num_chapitre ASC');
    print(t);
    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_chapitres = t;
      });
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage("Erreur", t[0]["error"].toString(), context);
    }
    setState(() {
      isload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDatalight,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            elevation: 2,
            backgroundColor: CupertinoColors.activeGreen,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.all(Radius.circular(15.0))),
            onPressed: isload
                ? null
                : () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => AdminAddChapitre({
                                  "num_chapitre": list_chapitres.length + 1,
                                  "id_cours": map_data["id"],
                                  "Titre": "-",
                                  "Contenu": null
                                })))).then((value) {
                      chargement();
                    });
                  },
            child: const Icon(
              FontAwesomeIcons.add,
              // size: 20,
              color: Colors.white,
            ),
          ),
          appBar: AppBar(
              centerTitle: true,
              elevation: 0.5,
              backgroundColor: Colors.white,
              leading: IconButton(
                  onPressed: () {
                    exitloading(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: CupertinoColors.activeGreen,
                  )),
              actions: [
                IconButton(
                    tooltip: "",
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => AdminListeComposition(map_data)));
                    },
                    icon: Icon(
                      CupertinoIcons.person_3_fill,
                      color: Colors.grey[500],
                    ))
              ],
              title: Text(
                map_data["Titre"].toString(),
                style: TextStyle(color: Colors.black, fontSize: 18),
              )),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: isload
                ? Center(
                    child: CupertinoActivityIndicator(),
                  )
                : list_chapitres.isEmpty
                    ? Center(
                        child: Text("Aucun chapitre n'a encore été enrégistré"),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 5),
                            //   child: Text(
                            //     "Chapitres".toUpperCase(),
                            //     textAlign: TextAlign.start,
                            //     style: TextStyle(
                            //         color: Colors.grey[800],
                            //         // fontSize: 13,
                            //         // letterSpacing: 1.0,
                            //         fontWeight: FontWeight.w600),
                            //   ),
                            // ),
                            const SizedBox(
                              height: 5,
                            ),
                            for (var i = 0; i < list_chapitres.length; i++)
                              Container(
                                // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 5),
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(0, 0),
                                          blurRadius: 5,
                                          color: Colors.grey[300]!)
                                    ],
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(7)),
                                width: double.infinity,
                                child: ListTile(
                                  onLongPress: () {
                                    showCupertinoModalPopup(
                                        filter: ImageFilter.blur(
                                            sigmaX: 5, sigmaY: 5),
                                        context: context,
                                        builder: (context) {
                                          return AlertActionChapitres(
                                              list_chapitres[i]);
                                        }).then((value) {
                                      chargement();
                                    });
                                  },
                                  title: Text(
                                    "Chapitre " +
                                        list_chapitres[i]['num_chapitre']
                                            .toString(),
                                    style: TextStyle(
                                        color: CupertinoColors.activeGreen),
                                  ),
                                  subtitle: Text(
                                      list_chapitres[i]['Titre'].toString()),
                                  trailing: OpenContainer(
                                    closedBuilder: (context, action) {
                                      return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: MaterialButton(
                                            disabledColor:
                                                CupertinoColors.activeGreen,
                                            disabledTextColor: Colors.white,
                                            color: CupertinoColors.activeGreen,
                                            textColor: Colors.white,
                                            elevation: 0,
                                            onPressed: list_chapitres[i]
                                                        ["quiz"] ==
                                                    null
                                                ? () async {
                                                    showloading(context);
                                                    Map<String, dynamic> conn =
                                                        await insert_data({
                                                      'id_chapitre':
                                                          list_chapitres[i]
                                                              ["id"],
                                                    }, "Quiz");
                                                    print("ici  ");
                                                    if (conn["status"] !=
                                                        "OK") {
                                                      exitloading(context);
                                                      showMessage(
                                                          "Désolé",
                                                          conn["message"]
                                                              .toString(),
                                                          context);

                                                      return;
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  "Questionnaire enrégistré ✅, vous pouvez maintenant editer les questions / réponses")));
                                                    }

                                                    exitloading(context);
                                                    chargement();
                                                  }
                                                : null,
                                            child: Text(
                                              list_chapitres[i]["quiz"] == null
                                                  ? "Ajouter Quiz"
                                                  : "Quiz",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ));
                                    },
                                    openBuilder: (context, fun) {
                                      return AdminQuiz({
                                        "id_chapitre": list_chapitres[i]["id"],
                                        "Titre_chapitre": list_chapitres[i]
                                            ["Titre"],
                                        "id": list_chapitres[i]["quiz"]
                                      });
                                    },
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
          )),
    );
  }
}

class AlertActionChapitres extends StatefulWidget {
  Map<String, dynamic> map_data;
  AlertActionChapitres(this.map_data);

  @override
  State<AlertActionChapitres> createState() => AlertActionChapitresState();
}

class AlertActionChapitresState extends State<AlertActionChapitres> {
  bool conf = false;
  String rest = '';
  Timer? timer;
  bool isload = false;
  Function()? click_sup = null;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      setState(() {
        click_sup = demarer_timer;
      });
    });
  }

  void demarer_timer() {
    setState(() {
      conf = true;
      rest = "( 5s )";
    });
    timer = Timer.periodic(Duration(seconds: 1), (timerr) {
      setState(() {
        rest = "( " + (5 - timerr.tick).toString() + "s )";
      });

      if (timerr.tick == 6) {
        setState(() {
          rest = "";
          timerr.cancel();
          click_sup = supression;
        });
      }
    });
    setState(() {
      click_sup = null;
    });
  }

  void supression() async {
    setState(() {
      isload = true;
    });
    var r = await exec_mysql_query(
        "DELETE from Chapitres WHERE id=" + widget.map_data["id"].toString());
    if (r != null && r) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Cours Supprimé ✅")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Une erreur s'est produite ")));
    }
    setState(() {
      isload = false;
    });
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.map_data["Titre"].toString()),
      content: isload
          ? Container(
              height: MediaQuery.of(context).size.height * .4,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Text(
                  "Chapitre : " + widget.map_data["num_chapitre"].toString(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7)),
                  child: CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) =>
                                      AdminAddChapitre(widget.map_data))))
                          .then((value) {
                        // chargement();
                      });
                    },
                    child: Text("Modifier"),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7)),
                  child: CupertinoDialogAction(
                    onPressed: click_sup,
                    child: Text(conf
                        ? "Confirmer la supression " + rest
                        : "Supprimer " + rest),
                    isDestructiveAction: true,
                  ),
                ),
              ],
            ),
    );
  }
}
