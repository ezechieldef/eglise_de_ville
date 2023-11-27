import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'package:time_range_picker/time_range_picker.dart';

import '../../api_operation.dart';

class AddProgramme extends StatefulWidget {
  Map<String, dynamic> map_data = {};

  AddProgramme(Map<String, dynamic> k) {
    if (k.isEmpty) {
      map_data = {
        "Date": null,
        "Titre": "",
        "Description": "",
        "Personne_Cible": "TOUS",
        "Repetition": "-",
        "Heure_Debut": null,
        "Heure_Fin": null
      };
    } else {
      k = dupliquer([k])[0];
      k.update(
          "Heure_Debut",
          (value) => TimeOfDay.fromDateTime(
              DateTime.parse("2000-01-01 " + value.toString())));
      k.update(
          "Heure_Fin",
          (value) => TimeOfDay.fromDateTime(
              DateTime.parse("2000-01-01 " + value.toString())));
      k.update("Date", (value) => DateTime.parse(value.toString()));
      map_data = k;
    }
  }

  @override
  State<AddProgramme> createState() => _AddProgrammeState(map_data);
}

class _AddProgrammeState extends State<AddProgramme> {
  Map<String, dynamic> map_data;
  _AddProgrammeState(this.map_data);
  List<Map<String, dynamic>> list_rpet = [
    {"code": "-", "label": "Désactivé"},
    {"code": "*", "label": "Infini"},
    // {"code": "+", "label": "Tous les __ de ce mois"},
  ];
  bool isload = false;
  void picktimeOnly(String name) async {
    var t = await showTimePicker(
        cancelText: "ANNULER",
        context: context,
        initialTime: map_data[name] ?? TimeOfDay.now());
    if (t != null) {
      setState(() {
        map_data.update(name, (value) => t);
      });
    }
  }

  void pickdate() async {
    var pic = await showDatePicker(
        context: context,
        locale: Locale("fr"),
        initialDate: DateTime.now().add(Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 30)));
    if (pic != null) {
      setState(() {
        map_data.update("Repetition", (value) => "-");
        map_data.update("Date", (value) => pic.toLocal());
        if (list_rpet.length > 2) list_rpet.removeLast();
        bool? ajout = false;
        DateTime? old_pic = pic;

        while (true) {
          old_pic = old_pic!.add(Duration(days: 1));
          if (old_pic.weekday == pic.weekday) {
            ajout = true;
            break;
          }

          if (old_pic.month != pic.month) {
            break;
          }
        }

        if (ajout != null && ajout == true)
          list_rpet.add({
            "code": "+",
            "label": "Tous les " +
                camelCase(DateFormat.EEEE("fr").format(pic)) +
                " de " +
                camelCase(DateFormat.yMMM("fr").format(pic))
          });
        ajout = null;
        old_pic = null;
      });
    }
  }

  String camelCase(String h) {
    var v = h.split(" ");
    var res;
    for (var i = 0; i < v.length; i++) {
      v[i] = v[i][0].toUpperCase() + v[i].substring(1);
    }
    return v.join(" ");
  }

  void boutton_ok() async {
    map_data.forEach((key, value) {
      if (value.runtimeType.toString() == "String") {
        map_data.update(key, (valu) => valu.toString().trim());
      }
    });
    if (map_data.containsValue("")) {
      print(map_data);
      showMessage("Incomplet",
          "Veuillez remplir tous les champs , puis réessez svp !", context);
      return;
    }
    TimeOfDay td1 = map_data["Heure_Debut"];
    TimeOfDay td2 = map_data["Heure_Fin"];

    if (td1.hour >= td2.hour) {
      showMessage("Erreur", "La séance doit durer au moins 1 H", context);
      return;
    }

    showloading(context);
    var temp = dupliquer([map_data])[0];
    temp.update("Date", (value) => value.toString());
    temp.update("Heure_Debut", (value) => formatTimeOfDay(value));
    temp.update("Heure_Fin", (value) => formatTimeOfDay(value));
    Map<String, dynamic> conn = await insert_data(temp, "Programme");

    if (conn["status"] != "OK") {
      exitloading(context);
      showMessage("Désolé", conn["message"].toString(), context);

      return;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Programme Ajouté ✅")));
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
          // backgroundColor: Colors.green,
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
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Colors.red,
              )),

          title: Text(
            "Formulaire Programme",
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: isload
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),

                      get_col_textfield("Titre"),
                      SizedBox(
                        height: 15,
                      ),
                      get_col_textfield("Description", maxi: 4, mini: 3),
                      SizedBox(
                        height: 15,
                      ),
                      get_col_textfield("Personne Cible"),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Flexible(
                              flex: 2,
                              child:
                                  get_col_cont_press("Date", "Date", pickdate)),
                          Flexible(
                              flex: 1,
                              child:
                                  get_col_cont_press("De", "Heure_Debut", () {
                                picktimeOnly("Heure_Debut");
                              })),
                          Flexible(
                              flex: 1,
                              child: get_col_cont_press(
                                  "à".toUpperCase(), "Heure_Fin", () {
                                picktimeOnly("Heure_Fin");
                              })),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        child: get_col_dropdown(
                            "Répétition", "Repetition", list_rpet),
                      ),
                      // SizedBox(
                      //   height: 15,
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 5, vertical: 20),
                      //   child: ClipRRect(
                      //     borderRadius: BorderRadius.circular(8),
                      //     child: MaterialButton(
                      //       onPressed: boutton_ok,
                      //       color: Colors.red,
                      //       minWidth: double.infinity,
                      //       textColor: Colors.white,
                      //       child: Padding(
                      //         padding: const EdgeInsets.symmetric(vertical: 11),
                      //         child: Text(
                      //           "OK",
                      //           style: TextStyle(fontWeight: FontWeight.w600),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
        ),
      ),
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
              initialValue: map_data[titre.replaceAll(" ", "_")].toString(),
              onChanged: (v) {
                setState(() {
                  map_data.update(titre.replaceAll(" ", "_"), (value) => v);
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
