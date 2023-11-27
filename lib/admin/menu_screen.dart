import 'package:eglise_de_ville/admin/admin_culte/culte.dart';
import 'package:eglise_de_ville/admin/admin_ecole/ecole_home.dart';
import 'package:eglise_de_ville/admin/admin_vision/vision.dart';
import 'package:eglise_de_ville/admin/gallery/upload_image.dart';
import 'package:eglise_de_ville/admin/lyrics/lyrics_admin.dart';
import 'package:eglise_de_ville/contact_us/contact_us.dart';
import 'package:eglise_de_ville/departement/departement.dart';
import 'package:eglise_de_ville/drawer.dart';
import 'package:eglise_de_ville/enseignement/enseignment.dart';
import 'package:eglise_de_ville/main.dart';
import 'package:eglise_de_ville/programmes/programmes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'admin_contact_us/contact_us.dart';
import 'admin_departement/departement.dart';
import 'admin_home.dart';
import 'admin_programme/programmes.dart';
import 'enseignement/enseignment.dart';

class DrawerScreen extends StatefulWidget {
  String index_str = "";
  dynamic page;
  DrawerScreen(this.index_str, this.page);
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  int pos = -1;
  List<dynamic> menus = [
    <String, dynamic>{
      "icon": CupertinoIcons.home,
      "titre": "Accueil",
      "class": AdminHome(drawerController),
      "pos": 0
    },
    <String, dynamic>{
      "icon": CupertinoIcons.book,
      "titre": "Enseignements",
      "class": AdminEnseignement(drawerController),
      "pos": 1
    },
    <String, dynamic>{
      "icon": CupertinoIcons.calendar,
      "titre": "Programmes",
      "class": AdminProgramme(drawerController),
      "pos": 2
    },
    <String, dynamic>{
      "icon": CupertinoIcons.person_2_alt,
      "titre": "Départements",
      "class": AdminDepartement(drawerController),
      "pos": 3
    },
    <String, dynamic>{
      "icon": CupertinoIcons.bubble_left_bubble_right,
      "titre": "Nos Coordonnées",
      "class": AdminContactUs(drawerController),
      "pos": 4
    },
    <String, dynamic>{
      "icon": CupertinoIcons.star,
      "titre": "Vision",
      "class": AdminVision(drawerController),
      "pos": 5
    },
    <String, dynamic>{
      "icon": CupertinoIcons.photo_camera,
      "titre": "Galerie Image",
      "class": UploadImageGallery(drawerController),
      "pos": 6
    },
    <String, dynamic>{
      "icon": CupertinoIcons.music_note_list,
      "titre": "Lyrics",
      "class": LyricsAdmin(drawerController),
      "pos": 7
    },
    <String, dynamic>{
      "icon": FontAwesomeIcons.houseChimney,
      "titre": "Cultes",
      "class": AdminCulte(drawerController),
      "pos": 8
    },
    <String, dynamic>{
      "icon": FontAwesomeIcons.personBreastfeeding,
      "titre": "Ecole",
      "class": AdminEcole(drawerController),
      "pos": 9
    },
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(top: 50, bottom: 50, left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DrawerHeader(child: Image.asset("assets/image/logo.png")),
            Flexible(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  controller: ScrollController(),
                  child: Column(
                    children: [
                      for (var element in menus)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                widget.page.set_main(element["class"]);
                                pos = element["pos"];
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  element['icon'],
                                  color: pos == element["pos"]
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.7),
                                  size: 25,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(element['titre'],
                                    style: TextStyle(
                                        color: pos == element["pos"]
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 17))
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => InitDrawer()));
              },
              child: Row(
                children: [
                  Icon(
                    Icons.exit_to_app,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Déconnexion',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
