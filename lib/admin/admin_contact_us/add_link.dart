import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'package:time_range_picker/time_range_picker.dart';

import '../../api_operation.dart';

class AddLien extends StatefulWidget {
  Map<String, dynamic> map_data = {};

  AddLien(Map<String, dynamic> k) {
    if (k.isEmpty) {
      map_data = {
        "Nom": null,
        "Description": "",
        "Lien": "",
      };
    } else {
      k = dupliquer([k])[0];
      map_data = k;
    }
  }

  @override
  State<AddLien> createState() => _AddLienState(map_data);
}

class _AddLienState extends State<AddLien> {
  Map<String, dynamic> map_data;
  _AddLienState(this.map_data);
  List<String> list_rpet = [
    "Facebook",
    "Instagram",
    "WhatsApp",
    "Site Web",
    "Email",
    "YouTube",
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

    showloading(context);
    var temp = dupliquer([map_data])[0];
    Map<String, dynamic> conn = await insert_data(temp, "Coordonnees");

    if (conn["status"] != "OK") {
      exitloading(context);
      showMessage("Désolé", conn["message"].toString(), context);

      return;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lien Ajouté ✅")));
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

                      // get_col_textfield("Nom"),
                      SizedBox(
                        child: get_col_dropdown("Nom", "Nom", list_rpet),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      get_col_textfield("Description", maxi: 2, mini: 2),
                      SizedBox(
                        height: 15,
                      ),

                      get_col_textfield("Lien"),
                      SizedBox(
                        height: 15,
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

  Widget get_col_dropdown(String titre, String name, List<String> list) {
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
                for (var i = 0; i < list.length; i++)
                  DropdownMenuItem<String>(value: list[i], child: Text(list[i]))
              ],
              onChanged: (Object? value) {
                setState(() {
                  map_data[name] = value;
                });
              },
              // onChanged: (Object? valuer) {

              // },
            ),
          )
        ],
      ),
    );
  }
}
