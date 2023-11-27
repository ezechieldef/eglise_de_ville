import 'dart:convert';

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

class AdminAddCours extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  AdminAddCours(Map<String, dynamic> k) {
    if (k.isEmpty) {
      map_data = {
        "Titre": "-",
        "Description": "-",
        "Image": '-',
        "Durée": 0,
        "Durée_repos": 0
      };
    } else {
      map_data = k;
    }
  }

  @override
  State<AdminAddCours> createState() => _AdminAddCoursState(this.map_data);
}

class _AdminAddCoursState extends State<AdminAddCours> {
  bool isload = false;
  Map<String, dynamic> map_data;

  _AdminAddCoursState(this.map_data) {}

  void btn_send() async {
    map_data.forEach((key, value) {
      if (value.runtimeType.toString() == "String") {
        map_data.update(key, (valu) => valu.toString().trim());
      }
    });

    if (map_data.containsValue("") ||
        map_data.containsValue("-") ||
        map_data.containsValue("0")) {
      print(map_data);
      showMessage("Incomplet",
          "Veuillez remplir tous les champs , puis réessez svp !", context);
      return;
    }
    showloading(context);
    Map<String, dynamic> conn = await insert_data(map_data, "Cours");
    print("ici  ");
    if (conn["status"] != "OK") {
      exitloading(context);
      showMessage("Désolé", conn["message"].toString(), context);

      return;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Cours Ajouté ✅")));
    }

    exitloading(context);
    exitloading(context);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDatalight,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.cyan,
            onPressed: () {
              btn_send();
            },
            child: Icon(
              FontAwesomeIcons.solidPaperPlane,
              // size: 20,
              color: Colors.white,
            ),
          ),
          appBar: AppBar(
            // centerTitle: true,
            elevation: 1,
            backgroundColor: Colors.white,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Colors.cyan,
                )),
    
            title: Text(
              'Formulaire : Cours',
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                        "Information : Pour le champs Image, vous devez y coller le lien d'une image que vous aviez déjà envoyé sur le serveur. \n\nVeuillez à ce que l'image ne soit pas dominé par des couleurs claires (blanc, jaune ...)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        )),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  get_col_textfield('Titre'),
                  SizedBox(
                    height: 15,
                  ),
                  get_col_textfield('Description', mini: 3, maxi: 5),
                  SizedBox(
                    height: 15,
                  ),
                  get_col_textfield('Image'),
                  SizedBox(
                    height: 15,
                  ),
                  get_col_textfield('Durée',
                      completer_titre: " ( nombre de jours )"),
                  SizedBox(
                    height: 15,
                  ),
                  get_col_textfield('Durée_repos',
                      completer_titre: " ( nombre de jours )")
                ],
              ),
            ),
          )),
    );
  }

  Widget get_col_textfield(String titre,
      {String completer_titre = "",
      bool isnumber = false,
      int mini = 1,
      int maxi = 1}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre.replaceAll("_", " ") + completer_titre),
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4)),
            child: TextFormField(
              keyboardType:
                  isnumber ? TextInputType.number : TextInputType.text,
              initialValue: isnumber
                  ? map_data[titre] == null
                      ? ""
                      : int.parse(map_data[titre].toString()).toString()
                  : map_data[titre].toString(),
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

  Widget get_col_datepick(String titre) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre),
          SizedBox(
            height: 5,
          ),
          InkWell(
            onTap: () async {
              var pic = await showDatePicker(
                  context: context,
                  locale: Locale("fr"),
                  initialDate: DateTime.tryParse(map_data[titre].toString()) ??
                      DateTime.now(),
                  firstDate: DateTime.now().subtract(Duration(days: 365 * 5)),
                  lastDate: DateTime.now().add(Duration(days: 30)));
              if (pic != null) {
                if (mounted)
                  setState(() {
                    map_data.update(titre, (value) => pic.toString());
                  });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4)),
              child: Text(map_data[titre].toString().isEmpty
                  ? "-"
                  : camelCase(DateFormat.yMMMMEEEEd("fr").format(
                      DateTime.parse(map_data[titre].toString().toString())))),
              // map_data[titre]
              //           .toString()
              //           .split(' ')
              //           .first
              //           .split("-")
              //           .reversed
              //           .join("/")
            ),
          )
        ],
      ),
    );
  }
}
