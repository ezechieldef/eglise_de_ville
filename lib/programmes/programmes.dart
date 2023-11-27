import 'dart:math';

import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/programmes/liste_pg.dart';
import 'package:eglise_de_ville/programmes/vue_calendrier.dart';
import 'package:eglise_de_ville/programmes/weekProgramme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';

class ProgramePage extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  ProgramePage(this.zoomDrawerController);

  @override
  State<ProgramePage> createState() => _ProgramePageState();
}

class _ProgramePageState extends State<ProgramePage> {
  int choix = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {
                widget.zoomDrawerController.toggle!();
              },
              icon: Icon(
                Icons.menu,
                color: Colors.red,
              )),
          actions: [
            Tooltip(
              message: "Calendrier",
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VueCalendrier()))
                        .then((value) {
                      // chargement();
                    });
                  },
                  icon: Icon(
                    CupertinoIcons.calendar,
                    color: Colors.grey,
                  )),
            )
          ],
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl(
                    groupValue: choix,
                    padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    children: {
                      0: Text("Tous les programmes"),
                      1: Text("Aujourd'hui")
                    },
                    onValueChanged: (v) {
                      setState(() {
                        choix = int.parse(v.toString());
                      });
                    }),
              ),
              SizedBox(
                height: 15,
              ),
              Flexible(child: choix == 1 ? ListePG1() : WeekProgramme())
              //
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> get_color(int pos, int index) {
    List<Map<String, dynamic>> color_list = [
      {"c": Colors.blue[300], "f": Colors.blue[600], "t": true},
      {"c": Colors.red[300], "f": Colors.red[600], "t": true},
      {
        "c": Color.fromRGBO(69, 229, 69, 1),
        "f": Color.fromARGB(255, 47, 185, 47),
        "t": true
      },
    ];
    var fff = {"c": Colors.grey[200]!, "t": false};
    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    Map<String, dynamic> m = {
      "c": Colors.grey[200]!,
      "t": false,
      "f": Colors.grey[300]
    };
    if (pos == 0) {
      m = color_list[index];
    }

    return m;
  }
}
