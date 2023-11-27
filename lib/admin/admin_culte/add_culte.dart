import 'dart:convert';

import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;

import 'package:time_range_picker/time_range_picker.dart';

import '../../api_operation.dart';

class AddCulte extends StatefulWidget {
  Map<String, dynamic> map_data = {};

  AddCulte(Map<String, dynamic> k) {
    if (k.isEmpty) {
      map_data = {
        "Titre": "",
        "Lien": "",
        "Audio": "",
        "Resume": "",
      };
    } else {
//      map_data = k;
      k.forEach((key, value) {
        if (value != "") {
          map_data[key] = value;
        }
      });
    }
  }

  @override
  State<AddCulte> createState() => _AddCulteState(map_data);
}

class _AddCulteState extends State<AddCulte> {
  Map<String, dynamic> map_data;
  _AddCulteState(this.map_data) {
    if (map_data["Resume"] != null) {
      _controller = fq.QuillController(
          document: fq.Document.fromJson(jsonDecode(map_data["Resume"])),
          selection: TextSelection.collapsed(offset: 0));
    }
  }

  bool isload = false;
  fq.QuillController _controller = fq.QuillController.basic();

  void boutton_ok() async {
    map_data.putIfAbsent("Resume", () => "");
    map_data.update("Resume",
        (value) => jsonEncode((_controller.document.toDelta().toJson())));
    // map_data.update("Date", (value) => value.toString());

    map_data.forEach((key, value) {
      if (value.runtimeType.toString() == "String") {
        map_data.update(key, (valu) => valu.toString().trim());
      }
    });
    for (var item in ['Titre', "Lien", "Resume"]) {
      if (map_data[item].toString().isEmpty) {
        print(map_data);
        showMessage("Incomplet",
            "Veuillez remplir tous les champs , puis réessayez svp !", context);
      }
    }

    showloading(context);

    Map<String, dynamic> conn = await insert_data(map_data, "Cultes");

    if (conn["status"] != "OK") {
      exitloading(context);
      showMessage("Désolé", conn["message"].toString(), context);

      return;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Culte Enregsitré ✅")));
    }

    exitloading(context);
    exitloading(context);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          floatingActionButton: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.blue,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.all(Radius.circular(15.0))),
            onPressed: () {
              boutton_ok();
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
            //backgroundColor: Colors.white,
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
                      builder: (context) => Theme(
                            data: themeData,
                            child: AlertDialog(
                                elevation: 0,
                                //backgroundColor: Colors.transparent,
                                content: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 20),
                                  decoration: BoxDecoration(
                                      //color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: IntrinsicHeight(
                                    child: Column(
                                      children: [
                                        get_col_textfield("Titre"),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        get_col_textfield("Lien"),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        get_col_textfield("Audio"),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 11),
                                              child: Text(
                                                "OK",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                          ));
                },
              ),
              SizedBox(
                width: 8,
              )
            ],

            title: Text(
              map_data["Titre"] ?? "-",
              style: TextStyle(fontSize: 15, color: textColor()),
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
                color:
                    isDark() ? Colors.white.withOpacity(0.2) : Colors.grey[200],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            margin: EdgeInsets.only(top: 10),
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        color: isDark()
                            ? Colors.white.withOpacity(0.3)
                            : Colors.white,
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

  Widget get_col_textfield(String titre,
      {String? name, bool number = false, int mini = 1, int maxi = 1}) {
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
                color:
                    isDark() ? Colors.white.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(4)),
            child: TextFormField(
              initialValue: map_data[name ?? titre].toString(),
              onChanged: (v) {
                setState(() {
                  map_data.update(name ?? titre, (value) => v);
                });
              },
              keyboardType: number
                  ? TextInputType.numberWithOptions()
                  : TextInputType.text,
              minLines: mini,
              maxLines: maxi,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          )
        ],
      ),
    );
  }

  Widget get_col_cont_press(String titre, String name, dynamic onpress) {
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
            onTap: onpress,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4)),
              child: Center(child: Text(formatstf(map_data[name]))),
            ),
          )
        ],
      ),
    );
  }

  Widget get_col_dropdown(String titre, String name, var list) {
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
            child: DropdownButton(
              isExpanded: true,
              underline: SizedBox(),
              value: map_data[name],
              items: [
                for (var item in list)
                  DropdownMenuItem(
                      value: item["code"],
                      child: Text(item["label"].toString()))
              ],
              onChanged: (Object? valuer) {
                setState(() {
                  map_data.update(name, (value) => valuer);
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
