import 'dart:ui';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contact_us/detail_contact.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

import '../contante_var2.dart';

class ContactUs extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  ContactUs(this.zoomDrawerController);

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  String camelCase(String h) {
    var v = h.split(" ");
    var res;
    for (var i = 0; i < v.length; i++) {
      v[i] = v[i][0].toUpperCase() + v[i].substring(1);
    }
    return v.join(" ");
  }

  show_links(String name) async {
    showloading(context);

    List<Map<String, dynamic>> list_lien = [];

    var t = await select_data("SELECT * from Coordonnees WHERE nom='$name'");
    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_lien = t;
      });
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage("Erreur", t[0]["error"].toString(), context);
      exitloading(context);
      return;
    }
    exitloading(context);
    if (list_lien.isEmpty) {
      showSimpleNotification(
          Text(
            "Aucun lien n'est disponible pour le moment, réessayer plus tard svp !",
          ),
          slideDismiss: true,
          subtitle: Text(name));
      return;
    }
    showCupertinoModalPopup(
        context: context,
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        builder: (context) => CupertinoAlertDialog(
              title: Text(name),
              content: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  for (var i = 0; i < list_lien.length; i++)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list_lien[i]["Description"].toString(),
                          style: TextStyle(fontFamily: 'SourceSansPro'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7)),
                            child: CupertinoDialogAction(
                              child: Text("Ouvrir"),
                              // isDestructiveAction: true,
                              onPressed: () {
                                launchUrl(
                                    Uri.parse(list_lien[i]["Lien"].toString()),
                                    mode: LaunchMode
                                        .externalNonBrowserApplication);
                                Navigator.pop(context);
                              },
                            )),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(7)),
                      child: CupertinoDialogAction(
                        child: Text("Annuler"),
                        // isDestructiveAction: true,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        // backgroundColor: Color(0xff282828),

        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
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
              ),
            ),
          ],
          leading: IconButton(
              onPressed: () {
                widget.zoomDrawerController.toggle!();
              },
              icon: Icon(
                Icons.menu,
                color: Colors.red,
              )),
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: 'EGLISE ',
                style: TextStyle(color: textColor(), fontFamily: "Montserrat"
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Container(
                //   width: double.infinity,
                //   // color: Colors.,
                //   height: MediaQuery.of(context).size.height * .4,
                //   child: LottieBuilder.asset("assets/lotties/contact.json"),
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  child: StaggeredGrid.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      get_item_button(2, 2.5, FontAwesomeIcons.facebookF,
                          "Facebook", null, [
                        Colors.blue,
                        Colors.blue[800]!,
                      ]),
                      get_item_button(
                          2, 2, FontAwesomeIcons.mailBulk, "Email", null, [
                        // Colors.teal,
                        // Colors.teal[700]!,
                        Color(0xff25D366), Colors.green[700]!
                      ]),
                      get_item_button(2, 2.5, FontAwesomeIcons.instagram,
                          "Instagram", null, [
                        Colors.blue,
                        Color(0xffC32AA3),
                        Color(0xffF46F30),
                      ]),
                      get_item_button(
                          2,
                          2.5,
                          FontAwesomeIcons.globe,
                          "Site Web",
                          null,
                          [Colors.orange, Colors.orange[800]!]),
                      get_item_button(2, 2.5, FontAwesomeIcons.map, "Maps",
                          Colors.white, [Colors.cyan, Colors.cyan[900]!]),
                      get_item_button(
                          2,
                          2,
                          FontAwesomeIcons.whatsapp,
                          "Whatsapp",
                          Colors.white,
                          [Color(0xff25D366), Colors.green[700]!]),
                      get_item_button(
                          4,
                          1.5,
                          FontAwesomeIcons.youtube,
                          "YouTube",
                          Colors.white,
                          [Colors.red, Colors.red[800]!]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get_item_button(int x, double y, IconData icon, String text, Color? c,
      List<Color>? gra_col) {
    return StaggeredGridTile.count(
      crossAxisCellCount: x,
      mainAxisCellCount: y,
      child: InkWell(
        onTap: () {
          show_links(text);
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => DetailContact(text)));
        },
        child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: c ?? Colors.white,
                gradient: gra_col == null
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gra_col),
                boxShadow: [
                  // BoxShadow(
                  //     color: Colors.black.withOpacity(0.3),
                  //     offset: Offset(2, 2),
                  //     blurRadius: 5)
                ]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FaIcon(
                  icon,
                  size: 50,
                  color: Colors.white,
                ),
                Text(
                  text,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                )
              ],
            )),
      ),
    );
  }
}
