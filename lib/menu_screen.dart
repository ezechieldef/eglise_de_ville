import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:eglise_de_ville/Ecole_Biblique/EcoleBiblique.dart';
import 'package:eglise_de_ville/admin/drawer.dart' as admindr;
import 'package:eglise_de_ville/bible/bible_home.dart';
import 'package:eglise_de_ville/contact_us/contact_us.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/culte/culte.dart';
import 'package:eglise_de_ville/departement/departement.dart';
import 'package:eglise_de_ville/don/don_acccueil.dart';
import 'package:eglise_de_ville/drawer.dart';
import 'package:eglise_de_ville/ecole/ecole_home.dart';
import 'package:eglise_de_ville/enseignement/enseignment.dart';
import 'package:eglise_de_ville/gallery/home_gallery.dart';
import 'package:eglise_de_ville/lyrics/lyrics_home.dart';
import 'package:eglise_de_ville/main.dart';
import 'package:eglise_de_ville/modal_admin_auth/modal_admin_auth.dart';
import 'package:eglise_de_ville/profile_view.dart';
import 'package:eglise_de_ville/programmes/programmes.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'HomePage/Home.dart';
import 'dimes/dimes_home.dart';
import 'vision/vision.dart';

class DrawerScreen extends StatefulWidget {
  String index_str = "";
  dynamic page;
  DrawerScreen(this.index_str, this.page);
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> implements listenerHome {
  int pos = -1;
  List<dynamic> menus = [
    <String, dynamic>{
      "icon": CupertinoIcons.home,
      "titre": "Accueil",
      "class": HomePage2(drawerController),
      "pos": 0
    },
    <String, dynamic>{
      "icon": Icons.multitrack_audio_rounded,
      "titre": "Ecole Biblique",
      "class": EcoleBiblique(drawerController),
      "pos": 1
    },
    <String, dynamic>{
      "icon": CupertinoIcons.book,
      "titre": "Enseignements",
      "class": EnseignementPage(drawerController),
      "pos": 2
    },
    <String, dynamic>{
      "icon": CupertinoIcons.calendar,
      "titre": "Programmes",
      "class": ProgramePage(drawerController),
      "pos": 3
    },
    // <String, dynamic>{
    //   "icon": CupertinoIcons.person_2_alt,
    //   "titre": "Départements",
    //   "class": DepartementPage(drawerController),
    //   "pos": 3
    // },
    <String, dynamic>{
      "icon": CupertinoIcons.bubble_left_bubble_right,
      "titre": "Nos Coordonnées",
      "class": ContactUs(drawerController),
      "pos": 4
    },
    <String, dynamic>{
      "icon": CupertinoIcons.star,
      "titre": "Vision",
      "class": VisionPage(drawerController),
      "pos": 5
    },
    <String, dynamic>{
      "icon": FontAwesomeIcons.handHoldingHeart,
      "titre": "Dîmes",
      "class": DimesHome(drawerController),
      "pos": 6
    },
    // <String, dynamic>{
    //   "icon": CupertinoIcons.photo_camera,
    //   "titre": "Galerie",
    //   "class": GalleryPhoto(drawerController),
    //   "pos": 6
    // },
    <String, dynamic>{
      "icon": CupertinoIcons.music_note_list,
      "titre": "Lyrics",
      "class": LyricsHome(drawerController),
      "pos": 7
    },
    <String, dynamic>{
      "icon": FontAwesomeIcons.houseChimney,
      "titre": "Cultes",
      "class": CultePage(drawerController),
      "pos": 8
    },
    <String, dynamic>{
      "icon": FontAwesomeIcons.bible,
      "titre": "Bible",
      "class": BibleHome(drawerController),
      "pos": 9
    },
    <String, dynamic>{
      "icon": FontAwesomeIcons.personBreastfeeding,
      "titre": "Ecole",
      "class": EcoleHome(drawerController),
      "pos": 10
    },
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cur_page = widget.page.main_screnn.runtimeType.toString();
  }

  String cur_page = "";
  int nbr = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 20, left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                child: InkWell(
                    onLongPress: () {
                      if (nbr < 3) {
                        setState(() {
                          nbr++;
                        });
                      } else {
                        setState(() {
                          nbr = 0;
                        });
                      }
                    },
                    child: Image.asset("assets/image/logo.png"))),
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
                                cur_page = widget.page.main_screnn.runtimeType
                                    .toString();
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  element['icon'],
                                  color: cur_page ==
                                          element["class"]
                                              .runtimeType
                                              .toString()
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.7),
                                  size: 25,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(element['titre'],
                                    style: TextStyle(
                                        color: cur_page ==
                                                element["class"]
                                                    .runtimeType
                                                    .toString()
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
            nbr != 3
                ? SizedBox()
                : InkWell(
                    onTap: () {
                      setState(() {
                        nbr = 0;
                      });
                      showCupertinoModalPopup(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          context: context,
                          builder: (context) => ModalAdminAuth());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Administration',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
            ProfileView()
          ],
        ),
      ),
    );
  }

  @override
  void click_menu(dynamic pageName) {
    // TODO: implement click_menu
    setState(() {
      cur_page = pageName.runtimeType.toString();
    });
  }
}
