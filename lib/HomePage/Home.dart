import 'dart:io';
import 'dart:math';

import 'package:eglise_de_ville/background_fetch_test/recuperation.dart';
import 'package:eglise_de_ville/background_fetch_test/test.dart';
import 'package:eglise_de_ville/comming_soon.dart';
import 'package:eglise_de_ville/contact_us/contact_us.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/departement/departement.dart';
import 'package:eglise_de_ville/don/don_acccueil.dart';
import 'package:eglise_de_ville/drawer.dart';
import 'package:eglise_de_ville/enseignement/enseignment.dart';
import 'package:eglise_de_ville/gallery/home_gallery.dart';
import 'package:eglise_de_ville/programmes/programmes.dart';
import 'package:eglise_de_ville/vision/vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

import '../contante_var2.dart';
import '../gallery/carousel_accueil.dart';
import '../sqlite_folder/principal.dart';

class HomePage2 extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  HomePage2(this.zoomDrawerController);

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // This callback is called every time the brightness changes.
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          // backgroundColor: Colors.grey[200],
          // extendBodyBehindAppBar: true,
          // extendBody: true,
          appBar: AppBar(
            centerTitle: true,
            elevation: 1,
            // backgroundColor: Color(
            //     0xffFAFAFA), //Colors.black.withOpacity(0.3), //Colors.white,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    themeData = isDark() ? themeDatalight : themeDatadark;
                  });
                },
                icon: Icon(
                  isDark()
                      ? CupertinoIcons.sun_max_fill
                      : CupertinoIcons.moon_stars_fill,
                  color: themeData.iconTheme.color!.withOpacity(.7),
                ),
              )
            ],
            leading: IconButton(
                onPressed: () {
                  widget.zoomDrawerController.toggle!();
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.red,
                )),
            // actions: [
            //   IconButton(
            //       onPressed: () async {
            //         // await raw_query_local("DELETE from Enseignement WHERE 1");
            //         // await raw_query_local("DELETE from Lyrics WHERE 1");
            //         // await raw_query_local("DELETE from Programme WHERE 1");
            //         var t =
            //             await select_local_sqlite("SELECT * FROM execution", []);
            //         // print(t);
            //         showDialog(
            //             context: context,
            //             builder: (c) => AlertDialog(
            //                   scrollable: true,
            //                   content: Text(t
            //                       .map((e) => "\n" + e.toString() + "\n")
            //                       .toList()
            //                       .toString()),
            //                 ));
            //         await recuperer_bg();
            //         // var t = await select_local_sqlite(
            //         //     "SELECT id from Enseignement", []);
            //         // print("resu $t");

            //         // t = await select_local_sqlite(
            //         //     "SELECT id from Enseignement", []);
            //         // print("resu2 $t");
            //         // // Navigator.push(context,
            //         //         MaterialPageRoute(builder: (context) => MyApp()))
            //         //     .then((value) {
            //         //   // chargement();
            //         // });
            //       },
            //       icon: Icon(
            //         FontAwesomeIcons.bell,
            //         size: 18,
            //         color: Colors.grey[600],
            //       ))
            // ],
            title: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: 'EGLISE ',
                  style:
                      TextStyle(color: textColor(), fontFamily: "Montserrat"),
                  children: [
                    TextSpan(
                      text: 'DE ',
                      style: TextStyle(
                        color: Colors.red[200],
                        // color: Colors.black,
                        fontWeight: FontWeight.w600,
                        // fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: 'VILLE',
                      style: TextStyle(
                        color: Colors.red,
                        // color: Colors.black,
                        fontWeight: FontWeight.w600,
                        // fontSize: 14,
                      ),
                    )
                  ]),
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            // color: Colors.white,
            // padding: EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    // height: MediaQuery.of(context).size.height * .2,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: CarouselAccuel(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: StaggeredGrid.count(
                        crossAxisCount: (Platform.isAndroid || Platform.isIOS)
                            ? 4
                            : (MediaQuery.of(context).size.width / 80).toInt(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("ecole biblique");
                                // pushr(EnseignementPage(
                                //     widget.zoomDrawerController));
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: get_col_menu(
                                    Icons.multitrack_audio_rounded,
                                    "Ecole Biblique",
                                    2),
                                decoration: get_menu_box_dec([
                                  // Colors.purple[300]!, Colors.purple[600]!
                                  Color.fromARGB(255, 2, 216, 198),
                                  Color(0xff50876D),
                                  // Color(0xffFF9671), Color(0xffFF6F91),
                                  // Color(0xffD65DB1),
                                ]),
                              ),
                            ),
                          ),

                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("bible");

                                // pushr(VisionPage(widget.zoomDrawerController));
                              },
                              child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: get_col_menu(
                                      FontAwesomeIcons.book, "Bible", 1),
                                  decoration: get_menu_box_dec([
                                    Color(0xff43e97b),

                                    CupertinoColors.activeGreen
                                    // Colors.teal[300]!,
                                    // Colors.teal[600]!
                                  ])),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 4,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("programme");
                                // pushr(ProgramePage(widget.zoomDrawerController));
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: get_col_menu(
                                    CupertinoIcons.calendar, "Programme", 0),
                                decoration: get_menu_box_dec([
                                  Colors.orange[300]!,
                                  Colors.orange,
                                ]),
                              ),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 2,
                            child: InkWell(
                              onTap: () {
                                pushr("enseignement");
                                // pushr(EnseignementPage(
                                //     widget.zoomDrawerController));
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: get_col_menu(CupertinoIcons.book_fill,
                                    "Enseignement", 3),
                                decoration: get_menu_box_dec([
                                  // Colors.purple[300]!, Colors.purple[600]!
                                  Color.fromARGB(255, 2, 216, 198),
                                  Color(0xff50876D),
                                  // Color(0xffFF9671), Color(0xffFF6F91),
                                  // Color(0xffD65DB1),
                                ]),
                              ),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("lyrics");

                                // pushr(VisionPage(widget.zoomDrawerController));
                              },
                              child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: get_col_menu(
                                      CupertinoIcons.music_note_list,
                                      "Lyrics ",
                                      2),
                                  decoration: get_menu_box_dec([
                                    Color(0xffffb199),
                                    Color(0xffff0844),

                                    // Colors.pink[200]!,
                                    // Colors.pink[600]!
                                  ])),
                            ),
                          ),

                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.8,
                            child: InkWell(
                              onTap: () {
                                pushr("ecole");
                                // pushr(
                                //     DepartementPage(widget.zoomDrawerController));
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                // margin: EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                child: get_col_menu(
                                    FontAwesomeIcons.personBreastfeeding,
                                    "Discipolat",
                                    4),
                                decoration: get_menu_box_dec([
                                  Color.fromARGB(255, 102, 226, 235),
                                  Color(0xff66a6ff),
                                  // Colors.cyan[300]!,
                                  // Colors.cyan[600]!
                                ]),
                              ),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("don");
                                // pushr(DonAccueil(widget.zoomDrawerController));
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: get_col_menu(
                                    FontAwesomeIcons.handHoldingHeart,
                                    "Don",
                                    9),
                                decoration: get_menu_box_dec([
                                  Color.fromARGB(255, 253, 204, 97),
                                  Color.fromARGB(255, 253, 204, 97),
                                  // Colors.blue[300]!,
                                  // Colors.blue[600]!,
                                ]),
                              ),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                // pushr("demande de priere");
                                pushr("comming soon");
                                // pushr(CommingSoon(widget.zoomDrawerController));
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: get_col_menu(
                                    FontAwesomeIcons.personPraying,
                                    "Demande de prière",
                                    5),
                                decoration: get_menu_box_dec([
                                  // Color.fromARGB(255, 9, 252, 70),
                                  // CupertinoColors.activeGreen,
                                  Color(0xffc71d6f),
                                  Color.fromARGB(255, 250, 108, 200),
                                  // Colors.green[300]!,
                                  // Colors.green[600]!,
                                ]),
                              ),
                            ),
                          ),

                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("culte");
                                // pushr(
                                //     DepartementPage(widget.zoomDrawerController));
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                // margin: EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                child: get_col_menu(
                                  FontAwesomeIcons.houseChimney,
                                  "Cultes",
                                  6,
                                ),
                                decoration: get_menu_box_dec([
                                  Color(0xfffc6076), Color(0xffff9a44),
                                  // Color(0xff86A8E7),
                                  // Color(0xffD16BA5)
                                  // Colors.red[300]!,
                                  // Colors.red[600]!
                                ]),
                              ),
                            ),
                          ),
                          //

                          // StaggeredGridTile.count(
                          //   crossAxisCellCount: 2,
                          //   mainAxisCellCount: 1.5,
                          //   child: InkWell(
                          //     onTap: () {
                          //       pushr("département");
                          //       // pushr(
                          //       //     DepartementPage(widget.zoomDrawerController));
                          //     },
                          //     child: Container(
                          //       width: double.infinity,
                          //       height: double.infinity,
                          //       // margin: EdgeInsets.symmetric(horizontal: 5),
                          //       alignment: Alignment.center,
                          //       child: get_col_menu(CupertinoIcons.person_2_alt,
                          //           "Département", 7),
                          //       decoration: get_menu_box_dec([
                          //         Colors.brown[300]!,
                          //         Colors.brown[600]!,
                          //       ]),
                          //     ),
                          //   ),
                          // ),
                          // StaggeredGridTile.count(
                          //   crossAxisCellCount: 2,
                          //   mainAxisCellCount: 1.5,
                          //   child: InkWell(
                          //     onTap: () {
                          //       pushr("galerie");
                          //       // pushr(GalleryPhoto(widget.zoomDrawerController));
                          //     },
                          //     child: Container(
                          //         width: double.infinity,
                          //         height: double.infinity,
                          //         alignment: Alignment.center,
                          //         child: get_col_menu(
                          //             CupertinoIcons.photo_camera_solid,
                          //             "Galerie Photo",
                          //             8),
                          //         decoration: get_menu_box_dec([
                          //           Colors.blue[300]!,
                          //           Colors.blue[600]!,
                          //         ])),
                          //   ),
                          // ),

                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.7,
                            child: InkWell(
                              onTap: () {
                                pushr("vision");

                                // pushr(VisionPage(widget.zoomDrawerController));
                              },
                              child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: get_col_menu(
                                      CupertinoIcons.star_circle_fill,
                                      "Vision",
                                      10),
                                  decoration: get_menu_box_dec([
                                    // Colors.pink[300]!, Colors.pink[600]!
                                    Color(0xff43e97b),

                                    CupertinoColors.activeGreen
                                  ])),
                            ),
                          ),

                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("dimes");
                                // pushr(
                                //     DepartementPage(widget.zoomDrawerController));
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                // margin: EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                child: get_col_menu(
                                  FontAwesomeIcons.handHoldingHeart,
                                  "Dîmes",
                                  1,
                                ),
                                decoration: get_menu_box_dec([
                                  Color(0xfffc6076), Color(0xffff9a44),
                                  // Color(0xff86A8E7),
                                  // Color(0xffD16BA5)
                                  // Colors.red[300]!,
                                  // Colors.red[600]!
                                ]),
                              ),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 4,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("contact");
                                // pushr(ContactUs(widget.zoomDrawerController))
                              },
                              child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: get_col_menu(
                                      CupertinoIcons
                                          .bubble_left_bubble_right_fill,
                                      "Nos Coordonnées",
                                      11),
                                  decoration: get_menu_box_dec([
                                    Color(0xffFF9671), Color(0xffFF6F91),
                                    Color(0xffD65DB1),
                                    // Colors.teal[400]!, Colors.teal[800]!
                                  ])),
                            ),
                          ),
                          // StaggeredGridTile.count(
                          //   crossAxisCellCount: 2,
                          //   mainAxisCellCount: 1.2,
                          //   child: InkWell(
                          //     onTap: () {
                          //       pushr("comming soon");
                          //     },
                          //     child: Container(
                          //       width: double.infinity,
                          //       height: double.infinity,
                          //       alignment: Alignment.center,
                          //       child: get_col_menu(
                          //           CupertinoIcons.settings, "Réglage",
                          //           color: Colors.red),
                          //       decoration: get_menu_box_dec([
                          //         Colors.brown[400]!,
                          //         Colors.brown[800]!,
                          //       ]),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          )),
    );
  }

  void pushr(dynamic p) {
    // listenerHome().click_menu(p);

    Navigator.pushAndRemoveUntil(
        context,
        routeTransition(InitDrawer(home_page: p)),
        // MaterialPageRoute(builder: (context) => InitDrawer(home_page: p)),
        (route) => false);
  }

  Widget get_col_menu(IconData iconData, String titre, int pos,
      {Color? color}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(
          iconData,
          color: color ?? get_color_p(pos),
          size: 35,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            titre,
            textAlign: TextAlign.center,
            style: TextStyle(
                // color:   Colors.grey[800],
                // fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  BoxDecoration get_menu_box_dec(List<Color> l) {
    return BoxDecoration(
      color: themeData.brightness == Brightness.light
          ? Colors.white
          : Colors.white.withOpacity(.4),
      border: Border.all(width: 0.3, color: Colors.grey.withOpacity(0.3)),
      boxShadow: [
        themeData.brightness == Brightness.light
            ? BoxShadow(
                offset: Offset(3, 3),
                blurRadius: 5,
                color: Colors.grey.withOpacity(0.4))
            : BoxShadow()
      ],
      borderRadius: BorderRadius.circular(7),
      // gradient: LinearGradient(
      //     begin: Alignment.topLeft, end: Alignment.bottomRight, colors: l)
    );
  }

  Color get_color_p(int index) {
    List<Color> color_list = [
      Colors.orange,
      CupertinoColors.activeGreen,
      Color.fromARGB(255, 250, 108, 200),
      Color.fromARGB(255, 252, 150, 119),
      Colors.lightBlue,
      Color(0xfffc6076),
      Colors.teal,
      Colors.blue,
      Colors.red[500]!,
    ];
    List<Color> color_list_dark = [
      Colors.orangeAccent,
      Color(0xff43e97b),
      Color.fromARGB(255, 250, 108, 200),
      Color(0xffffb199),
      Colors.lightBlue,
      Color(0xfffc6076),
      Colors.tealAccent,
      Colors.blue,
      Colors.redAccent,
    ];

    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    return themeData.brightness == Brightness.light
        ? color_list[index]
        : color_list_dark[index];
  }
}

class listenerHome {
  void click_menu(dynamic pageName) {}
}
