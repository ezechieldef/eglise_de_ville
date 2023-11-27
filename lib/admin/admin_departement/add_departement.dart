import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:time_range_picker/time_range_picker.dart';

import '../../api_operation.dart';

class AddDepartement extends StatefulWidget {
  Map<String, dynamic> map_data = {};

  AddDepartement(Map<String, dynamic> k) {
    if (k.isEmpty) {
      map_data = {
        "Titre": "",
        "Description": "",
        "Membres": 0,
        "lien_rejoindre": ""
      };
    } else {
      map_data = k;
    }
  }

  @override
  State<AddDepartement> createState() => _AddDepartementState(map_data);
}

class _AddDepartementState extends State<AddDepartement> {
  Map<String, dynamic> map_data;
  _AddDepartementState(this.map_data);

  bool isload = false;

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

    Map<String, dynamic> conn = await insert_data(map_data, "Departement");

    if (conn["status"] != "OK") {
      exitloading(context);
      showMessage("Désolé", conn["message"].toString(), context);

      return;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Département Enregsitré ✅")));
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
                color: Colors.red,
              )),

          title: Text(
            "Formulaire Département",
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
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
                      get_col_textfield("Lien Pour Rejoindre",
                          name: "lien_rejoindre"),
                      SizedBox(
                        height: 15,
                      ),

                      get_col_textfield("Nombres de personnes déjà membre",
                          name: "Membres", number: true),
                      SizedBox(
                        height: 15,
                      ),

                      // SizedBox(
                      //   height: 15,
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: MaterialButton(
                            onPressed: boutton_ok,
                            color: Colors.red,
                            minWidth: double.infinity,
                            textColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              child: Text(
                                "OK",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
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
                color: Colors.grey[100],
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
