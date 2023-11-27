import 'dart:convert';

import 'package:eglise_de_ville/contante_var2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:overlay_support/overlay_support.dart';

class AddQuestionQuiz extends StatefulWidget {
  Map<String, dynamic> map_quiz;

  AddQuestionQuiz(this.map_quiz);

  @override
  State<AddQuestionQuiz> createState() => _AddQuestionQuizState(this.map_quiz);
}

class _AddQuestionQuizState extends State<AddQuestionQuiz> {
  Map<String, dynamic> map_quiz = {};

  String saisi = "";

  TextEditingController controller = TextEditingController();
  _AddQuestionQuizState(this.map_quiz) {}
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
            color: isDark() ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              get_col_textfield("question",
                  renommer: "Poser votre question : ", mini: 2, maxi: 2),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Text(
                  "Réponses",
                  style: TextStyle(color: textColor()),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: get_container(Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    child: Wrap(
                      children: [
                        for (var i = 0; i < map_quiz["reponses"].length; i++)
                          InkWell(
                            onLongPress: () {
                              var temp = map_quiz["reponses"][i];
                              showSimpleNotification(
                                  Text("Réponse $temp supprimé"),
                                  background: Colors.grey[900]!,
                                  trailing: MaterialButton(
                                    textColor: Colors.yellow,
                                    onPressed: () {
                                      try {
                                        setState(() {
                                          map_quiz["reponses"].insert(i, temp);
                                        });
                                      } catch (e) {
                                        setState(() {
                                          map_quiz["reponses"].add(temp);
                                        });
                                      }
                                    },
                                    child: Text("Annuler"),
                                  ));

                              setState(() {
                                map_quiz["reponses"].removeAt(i);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 7),
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(0, 0),
                                        blurRadius: 2)
                                  ]),
                              child: Text(
                                map_quiz["reponses"][i],
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                      ],
                    ),
                  ))),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: get_container(TextField(
                  controller: controller,
                  onSubmitted: (v) {
                    if (v.toString().trim().isNotEmpty) {
                      add_to_resp();
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      saisi = value;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: map_quiz["reponses"].isEmpty
                          ? "Entrer la réponse correcte"
                          : 'Entrer une fausse réponse',
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        color: Colors.blue,
                        onPressed: saisi.trim().isEmpty ? null : add_to_resp,
                        icon: Icon(
                          Icons.add_circle,
                          color: Colors.deepOrange,
                        ),
                      )),
                )),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: MaterialButton(
                  color: CupertinoColors.activeGreen,
                  textColor: Colors.white,
                  minWidth: double.infinity,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  onPressed: map_quiz["reponses"].length > 1 &&
                          map_quiz["question"].trim().isNotEmpty
                      ? btn_send
                      : null,
                  child: Text(
                    "Sauvegarder",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }

  void btn_send() {
    Navigator.pop(context, map_quiz);
  }

  void add_to_resp() {
    if (map_quiz["reponses"].length < 4 && controller.text.length <= 50) {
      setState(() {
        map_quiz["reponses"].add(controller.text.trim());
      });
      controller.text = "";
    } else if (map_quiz["reponses"].length >= 4) {
      showSimpleNotification(
        Text("Quatres réponses au maximum svp !"),
        background: Colors.grey[900]!,
      );
    } else if (controller.text.length > 50) {
      showSimpleNotification(
        Text("Entrez une réponse un peu plus courte svp !"),
        background: Colors.grey[900]!,
      );
    }
  }

  Widget get_container(Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.1),
          borderRadius: BorderRadius.circular(4)),
      width: double.infinity,
      child: child,
    );
  }

  Widget get_col_textfield(String titre,
      {bool readonly = false,
      String? renommer,
      String? suff,
      int mini = 1,
      int maxi = 1}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              renommer ?? titre,
              style: TextStyle(color: textColor()),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.1),
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
      ),
    );
  }
}
