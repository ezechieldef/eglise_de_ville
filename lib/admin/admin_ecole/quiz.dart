import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:eglise_de_ville/admin/admin_ecole/add_chapitre.dart';
import 'package:eglise_de_ville/admin/admin_ecole/add_question_quiz.dart';
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

class AdminQuiz extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  AdminQuiz(Map<String, dynamic> k) {
    map_data = k;
  }

  @override
  State<AdminQuiz> createState() => _AdminQuizState(this.map_data);
}

class _AdminQuizState extends State<AdminQuiz> {
  bool isload = false;
  Map<String, dynamic> map_data;
  Map<String, dynamic> map_quiz = {};

  _AdminQuizState(this.map_data) {}

  List<Map<String, dynamic>> list_questions = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargement();
  }

  void chargement() async {
    // print(jsonEncode([
    //   {
    //     "question": "Ca va ?",
    //     "reponses": ["Oui", "NON"]
    //   }
    // ]));
    // return;
    setState(() {
      isload = true;
      list_questions = [];
    });
    var t = await select_data(
        'SELECT * from Quiz C WHERE id=\'' + map_data["id"].toString() + '\' ');
    print(t);
    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        map_quiz = t.first;
        List<Map<String, dynamic>> l = [];
        jsonDecode(t.first["questions"].toString()).forEach((element) {
          Map<String, dynamic> m = {};
          element.forEach((key, value) {
            m[key] = value;
          });
          l.add(m);
        });
        list_questions = l;
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
      data: themeData,
      child: Scaffold(
          resizeToAvoidBottomInset: true,

          // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          // floatingActionButton: FloatingActionButton(
          //   mini: true,
          //   elevation: 0,
          //   backgroundColor: CupertinoColors.activeGreen,
          //   // shape: RoundedRectangleBorder(
          //   //     borderRadius: BorderRadius.all(Radius.circular(15.0))),

          //   onPressed: isload
          //       ? null
          //       : () {
          //           showModalBottomSheet(
          //                   context: context,
          //                   isScrollControlled: true,
          //                   backgroundColor: Colors.transparent,
          //                   builder: (context) =>
          //                       AddQuestionQuiz({"question": "", 'reponses': []}))
          //               .then((value) {
          //             if (value != null) {
          //               setState(() {
          //                 list_questions.add(value);
          //               });
          //             }
          //           });

          //         },
          //   child: const Icon(
          //     FontAwesomeIcons.add,
          //     // size: 20,
          //     color: Colors.white,
          //   ),
          // ),

          appBar: AppBar(
              centerTitle: true,
              elevation: 0.5,
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
              title: Text(
                "Quiz : " + map_data["Titre_chapitre"].toString(),
              )),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: isload
                ? Center(
                    child: CupertinoActivityIndicator(),
                  )
                : Column(
                    children: [
                      Flexible(
                        child: SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    "Seuil de réussite " +
                                        map_quiz["reussite"].toString() +
                                        "%  ( Soit " +
                                        (list_questions.length *
                                                map_quiz["reussite"] /
                                                100)
                                            .toInt()
                                            .toString() +
                                        " bonnes réponse / " +
                                        list_questions.length.toString() +
                                        "  )",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(

                                        // fontSize: 13,
                                        // letterSpacing: 1.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                RangeSlider(
                                  min: 0,
                                  max: 100,
                                  divisions: 4,
                                  labels: RangeLabels(
                                      '0 %',
                                      int.parse(map_quiz["reussite"].toString())
                                              .toString() +
                                          ' %'),
                                  activeColor: CupertinoColors.activeGreen,
                                  values: RangeValues(
                                      0,
                                      double.parse(
                                          map_quiz["reussite"].toString())),
                                  onChanged: (v) {
                                    setState(() {
                                      if (v.end >= 25) {
                                        map_quiz.update("reussite",
                                            (value) => v.end.toInt());
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                // SizedBox(height: 20),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    "Questions",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(

                                        // fontSize: 13,
                                        // letterSpacing: 1.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(height: 10),
                                list_questions.isEmpty
                                    ? Center(
                                        child: Text(
                                            "Aucune question n'a encore été enrégistré"),
                                      )
                                    : SizedBox(),
                                for (var i = 0; i < list_questions.length; i++)
                                  Container(
                                    // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 5),

                                    width: double.infinity,
                                    child: ListTile(
                                      onLongPress: () {
                                        showCupertinoModalPopup(
                                            filter: ImageFilter.blur(
                                                sigmaX: 5, sigmaY: 5),
                                            context: context,
                                            builder: (context) {
                                              return AlertActionQuestion(
                                                  list_questions[i]);
                                            }).then((value) {
                                          if (value != null && value) {
                                            setState(() {
                                              list_questions.removeAt(i);
                                            });
                                          } else {
                                            setState(() {
                                              list_questions = list_questions;
                                            });
                                          }
                                        });
                                      },
                                      title: Text(
                                        (i + 1).toString() +
                                            ". " +
                                            list_questions[i]['question']
                                                .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(list_questions[i]
                                              ["reponses"]
                                          .join(', ')
                                          .toString()),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Row(
                          children: [
                            Flexible(
                                child: MaterialButton(
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 5),
                                    textColor: Colors.white,
                                    minWidth: double.infinity,
                                    color: Colors.orange,
                                    child: Text(
                                      "Nouvelle Question",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    onPressed: () {
                                      showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) =>
                                              AddQuestionQuiz({
                                                "question": "",
                                                'reponses': []
                                              })).then((value) {
                                        if (value != null) {
                                          setState(() {
                                            list_questions.add(value);
                                          });
                                        }
                                      });
                                    })),
                            SizedBox(
                              width: 15,
                            ),
                            Flexible(
                                child: MaterialButton(
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 5),
                                    textColor: Colors.white,
                                    minWidth: double.infinity,
                                    child: Text(
                                      "Sauvegarder",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    color: CupertinoColors.activeGreen,
                                    onPressed: btn_send)),
                          ],
                        ),
                      )
                    ],
                  ),
          )),
    );
  }

  void btn_send() async {
    map_quiz.forEach((key, value) {
      if (value.runtimeType.toString() == "String") {
        map_quiz.update(key, (valu) => valu.toString().trim());
      }
    });
    map_quiz.update("questions", (value) => jsonEncode(list_questions));

    if (map_quiz.containsValue("") || map_data.containsValue("-")) {
      print(map_quiz);
      showMessage("Incomplet",
          "Veuillez remplir tous les champs , puis réessez svp !", context);
      return;
    }
    showloading(context);
    Map<String, dynamic> conn = await insert_data(map_quiz, "Quiz");
    print("ici  ");
    if (conn["status"] != "OK") {
      exitloading(context);
      showMessage("Désolé", conn["message"].toString(), context);

      return;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Questionnaire Sauvegarder ✅")));
    }

    exitloading(context);
    exitloading(context);
  }

  Widget get_col_textfield(String titre,
      {bool readonly = false,
      String? renommer,
      String? suff,
      int mini = 1,
      int maxi = 1}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(renommer ?? titre),
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4)),
            child: TextFormField(
              readOnly: readonly,
              initialValue: map_quiz[titre].toString(),
              onChanged: (v) {
                setState(() {
                  map_quiz.update(titre, (value) => v);
                });
              },
              minLines: mini,
              maxLines: maxi,
              decoration:
                  InputDecoration(border: InputBorder.none, suffixText: suff),
            ),
          )
        ],
      ),
    );
  }
}

class AlertActionQuestion extends StatefulWidget {
  Map<String, dynamic> map_data;
  AlertActionQuestion(this.map_data);

  @override
  State<AlertActionQuestion> createState() => AlertActionQuestionState();
}

class AlertActionQuestionState extends State<AlertActionQuestion> {
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
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.map_data["question"].toString()),
      content: isload
          ? Container(
              height: MediaQuery.of(context).size.height * .4,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Text(
                  "Réponses : " + widget.map_data["reponses"].toString(),
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
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              AddQuestionQuiz(widget.map_data)).then((value) {
                        // chargement();
                        Navigator.pop(context);
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
