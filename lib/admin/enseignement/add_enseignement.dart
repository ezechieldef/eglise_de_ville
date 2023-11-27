import 'dart:convert';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:html_editor/html_editor.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../contante_var2.dart';
import '../../contantes.dart';
import 'package:intl/intl.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

class AdminAddEnseignemnt extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  AdminAddEnseignemnt(Map<String, dynamic> k) {
    if (k.isEmpty) {
      map_data = {
        "Titre": "-",
        "Verset": "-",
        "Contenu": null,
        "Date": DateTime.now()
      };
    } else {
      map_data = k;
    }
  }

  @override
  State<AdminAddEnseignemnt> createState() =>
      _AdminAddEnseignemntState(this.map_data);
}

class _AdminAddEnseignemntState extends State<AdminAddEnseignemnt> {
  bool isload = false;
  Map<String, dynamic> map_data;
  fq.QuillController _controller = fq.QuillController.basic();

  _AdminAddEnseignemntState(this.map_data) {
    if (map_data["Contenu"] != null) {
      _controller = fq.QuillController(
          document: fq.Document.fromJson(jsonDecode(map_data["Contenu"])),
          selection: TextSelection.collapsed(offset: 0));
    }
  }

  void btn_send() async {
    map_data.update("Contenu",
        (value) => jsonEncode((_controller.document.toDelta().toJson())));
    map_data.update("Date", (value) => value.toString());
    map_data.forEach((key, value) {
      if (value.runtimeType.toString() == "String") {
        map_data.update(key, (valu) => valu.toString().trim());
      }
    });

    if (map_data.containsValue("") || map_data.containsValue("-")) {
      print(map_data);
      showMessage("Incomplet",
          "Veuillez remplir tous les champs , puis réessez svp !", context);
      return;
    }
    showloading(context);
    Map<String, dynamic> conn = await insert_data(map_data, "Enseignement");
    print("ici  ");
    if (conn["status"] != "OK") {
      exitloading(context);
      showMessage("Désolé", conn["message"].toString(), context);

      return;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enseignement Ajouté ✅")));
    }

    exitloading(context);
    exitloading(context);
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDatalight,

      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.pink,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.all(Radius.circular(15.0))),
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
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Colors.red,
                )),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.edit_note_rounded,
                  color: Colors.grey,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          content: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            width: MediaQuery.of(context).size.width * .9,
                            child: IntrinsicHeight(
                              child: Column(
                                children: [
                                  get_col_textfield("Titre"),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  get_col_textfield("Verset"),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  get_col_datepick("Date"),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                    child: MaterialButton(
                                      onPressed: () {
                                        if (Navigator.canPop(context))
                                          Navigator.pop(context);
                                      },
                                      color: Colors.white,
                                      elevation: 2,
                                      minWidth: double.infinity,
                                      textColor: Colors.red,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 11),
                                        child: Text(
                                          "OK",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )));
                },
              ),
              SizedBox(
                width: 8,
              )
            ],
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  map_data["Titre"].toString(),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700]),
                ),
                Text(
                  map_data["Verset"].toString(),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            margin: EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: fq.QuillToolbar.basic(controller: _controller)),
                SizedBox(
                  height: 20,
                ),
                Flexible(
                  child: isload
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: fq.QuillEditor.basic(
                            controller: _controller,
                            readOnly: false, // true for view only mode
                          ),
                        ),
                ),
                // SizedBox(height: 55)
              ],
            ),
          )),
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
