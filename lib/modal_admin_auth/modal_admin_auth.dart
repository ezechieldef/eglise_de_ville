import 'dart:ui';

import 'package:eglise_de_ville/admin/drawer.dart';
import 'package:eglise_de_ville/api_operation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../contantes.dart';

class ModalAdminAuth extends StatefulWidget {
  @override
  State<ModalAdminAuth> createState() => _ModalAdminAuthState();
}

class _ModalAdminAuthState extends State<ModalAdminAuth> {
  bool isload = false;
  bool showpass = false;
  Map<String, String> map_data = {"Identifiant": "", "MotDePasse": ""};
  void connexion() async {
    if (map_data.containsValue("")) {
      showMessage(
          "Imcomplet", "Remplissez d'abord tous les champs svp !", context);
      return;
    }
    if (mounted)
      setState(() {
        isload = true;
      });
    String req = "SELECT * from Admins WHERE BINARY Identifiant='" +
        map_data["Identifiant"].toString().replaceAll("'", "''") +
        "' AND BINARY Password='" +
        map_data["MotDePasse"].toString().replaceAll("'", "''") +
        "' ";
    var t = await select_data(req);
    print("requete ! $req");

    if (t != null && t.isEmpty) {
      showMessage("Echec", 'Identifiant / Mot de passe Incorrect', context);
      if (mounted)
        setState(() {
          isload = false;
        });
    } else if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      if (mounted) admin_id = int.tryParse(t[0]["id"].toString()) ?? 0;
      if (mounted)
        setState(() {
          isload = false;
        });
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: ((context) => InitDrawerAdmin())));
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      if (mounted)
        setState(() {
          isload = false;
        });
      showMessage("Erreur", t[0]["error"].toString(), context);
    }

    isload = false;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(primarySwatch: Colors.teal, fontFamily: "SourceSansPro"),
      child: AlertDialog(
        content: Container(
          width: MediaQuery.of(context).size.width * .7,
          child: isload
              ? SizedBox(
                  height: 150,
                  child: CupertinoActivityIndicator(),
                )
              : IntrinsicHeight(
                  child: Column(
                  children: [
                    Text("Authentification"),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey[200]!,
                          borderRadius: BorderRadius.circular(5)),
                      child: TextFormField(
                        onChanged: (v) {
                          setState(() {
                            map_data.update(
                                "Identifiant", (value) => v.toString().trim());
                          });
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: "Identifiant"),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey[200]!,
                          borderRadius: BorderRadius.circular(5)),
                      child: TextFormField(
                        obscureText: !showpass,
                        onChanged: (v) {
                          setState(() {
                            map_data.update(
                                "MotDePasse", (value) => v.toString());
                          });
                        },
                        onFieldSubmitted: (v) {
                          if (!map_data.containsValue("")) {
                            connexion();
                          }
                        },
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showpass = !showpass;
                                  });
                                },
                                icon: Icon(!showpass
                                    ? Icons.remove_red_eye
                                    : FontAwesomeIcons.eyeSlash)),
                            border: InputBorder.none,
                            hintText: "Mot de passe"),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            // color: Colors.grey[100],
                            minWidth: double.infinity,
                            textColor: Colors.black,
                            elevation: 0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                "Annuler",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Flexible(
                          child: MaterialButton(
                            onPressed:
                                map_data.containsValue("") ? null : connexion,
                            color: Colors.teal,
                            minWidth: double.infinity,
                            textColor: Colors.white,
                            elevation: 0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                "Connexion",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )),
        ),
      ),
    );
  }
}
