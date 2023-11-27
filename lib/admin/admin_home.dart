import 'package:eglise_de_ville/admin/drawer.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/drawer.dart';
import 'package:eglise_de_ville/programmes/programmes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

import '../gallery/carousel_accueil.dart';
import 'gallery/upload_carousel.dart';

class AdminHome extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  AdminHome(this.zoomDrawerController);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDatalight,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Color(0xffFAFAFA),
          // backgroundColor: Colors.grey[200],
          // extendBodyBehindAppBar: true,
          // extendBody: true,
          appBar: AppBar(
            centerTitle: true,
            elevation: 1,
            backgroundColor: Color(
                0xffFAFAFA), //Colors.black.withOpacity(0.3), //Colors.white,
            leading: IconButton(
                onPressed: () {
                  widget.zoomDrawerController.toggle!();
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.red,
                )),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    FontAwesomeIcons.bell,
                    size: 18,
                    color: Colors.grey[600],
                  ))
            ],
            title: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: 'EGLISE ',
                  style: TextStyle(color: Colors.black, fontFamily: "Montserrat"
                      // color: Colors.black,
                      // fontSize: 14,
                      ),
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
                  Text(
                    "Administration",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .2,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[200]),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context, routeTransition(UploadGIFCarousel()));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: CarouselAccuel(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: StaggeredGrid.count(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          // StaggeredGridTile.count(
                          //   crossAxisCellCount: 4,
                          //   mainAxisCellCount: 2,
                          //   child: Container(
                          //     width: double.infinity,
                          //     height: double.infinity,
                          //     alignment: Alignment.center,
                          //     child: Text(
                          //       "Derniere image de la gallerie",
                          //       style: TextStyle(color: Colors.white),
                          //     ),
                          //     decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(7),
                          //         boxShadow: [
                          //           BoxShadow(
                          //               offset: Offset(4, 4),
                          //               blurRadius: 5,
                          //               color: Colors.grey[300]!)
                          //         ],
                          //         gradient: LinearGradient(
                          //             begin: Alignment.topLeft,
                          //             end: Alignment.bottomRight,
                          //             colors: [
                          //               Colors.red[300]!,
                          //               Colors.red[700]!
                          //             ])),
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 20,
                          //   width: double.infinity,
                          // ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 4,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("adminprogramme");
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: get_col_menu(
                                    CupertinoIcons.calendar, "Programme",
                                    color: Colors.orange),
                                decoration: get_menu_box_dec(
                                    [Colors.orange, Colors.deepOrange]),
                              ),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("vision");
                              },
                              child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: get_col_menu(
                                      CupertinoIcons.star_circle_fill, "Vision",
                                      color: Colors.green[600]!),
                                  decoration: get_menu_box_dec([
                                    Colors.green[400]!,
                                    Colors.green[600]!
                                  ])),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 2,
                            child: InkWell(
                              onTap: () {
                                pushr("enseignement");
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: get_col_menu(
                                    CupertinoIcons.book_fill, "Enseignement",
                                    color: Colors.pink),
                                decoration: get_menu_box_dec(
                                    [Colors.pink[400]!, Colors.pink[600]!]),
                              ),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 2,
                            child: InkWell(
                              onTap: () {
                                pushr("demande de priere");
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: get_col_menu(
                                    FontAwesomeIcons.personPraying,
                                    "Demande de prière",
                                    color: Colors.purple),
                                decoration: get_menu_box_dec(
                                    [Colors.purple[400]!, Colors.purple[600]!]),
                              ),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("culte");
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                // margin: EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                child: get_col_menu(
                                    FontAwesomeIcons.houseChimney, "Cultes",
                                    color: Colors.blue),
                                decoration: get_menu_box_dec(
                                    [Colors.blue[400]!, Colors.blue[800]!]),
                              ),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("département");
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                // margin: EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                child: get_col_menu(
                                    CupertinoIcons.person_2_alt, "Département",
                                    color: Colors.orange),
                                decoration: get_menu_box_dec(
                                    [Colors.blue[400]!, Colors.blue[800]!]),
                              ),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("gallery");
                              },
                              child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: get_col_menu(
                                      CupertinoIcons.photo_camera_solid,
                                      "Galerie Photo",
                                      color: Colors.teal),
                                  decoration: get_menu_box_dec(
                                      [Colors.teal[400]!, Colors.teal[800]!])),
                            ),
                          ),

                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("contact");
                              },
                              child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: get_col_menu(
                                      CupertinoIcons
                                          .bubble_left_bubble_right_fill,
                                      "Nos Coordonnées",
                                      color: Colors.indigo),
                                  decoration: get_menu_box_dec(
                                      [Colors.teal[400]!, Colors.teal[800]!])),
                            ),
                          ),

                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("lyrics");
                              },
                              child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: get_col_menu(
                                      CupertinoIcons.music_note_list, "Lyrics",
                                      color: Colors.pink),
                                  decoration: get_menu_box_dec(
                                      [Colors.teal[400]!, Colors.teal[800]!])),
                            ),
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 1.5,
                            child: InkWell(
                              onTap: () {
                                pushr("dimes");
                                // pushr(DonAccueil(widget.zoomDrawerController));
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: get_col_menu(
                                    FontAwesomeIcons.handHoldingHeart, "Dîmes",
                                    color: Colors.green),
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
                                pushr("ecole");
                              },
                              child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: get_col_menu(
                                      FontAwesomeIcons.personBreastfeeding,
                                      "Ecole",
                                      color: Colors.cyan),
                                  decoration: get_menu_box_dec(
                                      [Colors.teal[400]!, Colors.teal[800]!])),
                            ),
                          ),
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
    Navigator.pushAndRemoveUntil(
        context,
        routeTransition(InitDrawerAdmin(home_page: p)),
        // MaterialPageRoute(builder: (context) => InitDrawerAdmin(home_page: p)),
        (route) => false);
  }

  Widget get_col_menu(IconData iconData, String titre,
      {Color color = Colors.white}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(
          iconData,
          color: color,
          size: 35,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            titre,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey[800],
                // fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  BoxDecoration get_menu_box_dec(List<Color> l) {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(width: 0.3, color: Colors.grey.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
            offset: Offset(3, 3),
            blurRadius: 5,
            color: Colors.grey.withOpacity(0.4))
      ],
      borderRadius: BorderRadius.circular(7),
      // gradient: LinearGradient(
      //     begin: Alignment.topLeft, end: Alignment.bottomRight, colors: l)
    );
  }
}
