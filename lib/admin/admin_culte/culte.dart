import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:eglise_de_ville/admin/admin_culte/add_culte.dart';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:lecle_flutter_link_preview/lecle_flutter_link_preview.dart';
// import 'package:simple_url_preview/simple_url_preview.dart';

import 'package:url_launcher/url_launcher.dart' as ul;
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:intl/intl.dart';
import '../../contantes.dart';

class AdminCulte extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  AdminCulte(this.zoomDrawerController);

  @override
  State<AdminCulte> createState() => _AdminCulteState();
}

class _AdminCulteState extends State<AdminCulte> {
  List<Map<String, dynamic>> list_culte = [];
  bool isload = false;
  void chargement() async {
    setState(() {
      isload = true;
    });
    var t = await select_data("SELECT * from Cultes ORDER BY Date DESC");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_culte = t;
      });
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage("Erreur", t[0]["error"].toString(), context);
    }
    setState(() {
      isload = false;
    });
  }

  void btn_rejoindre(int index) async {
    try {
      await ul
          .launchUrl(Uri.parse(list_culte[index]["lien_rejoindre"].toString()));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Une erreur s'est produite 🙁 !")));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargement();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDatalight,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => AddCulte({}))))
                  .then((value) {
                chargement();
              });
            },
            child: Icon(Icons.add)),
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
                onPressed: () {
                  chargement();
                },
                icon: Icon(
                  CupertinoIcons.refresh_circled_solid,
                  color: Colors.grey,
                ))
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
          // margin: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Text(
                  "Cultes".toUpperCase(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.grey[800],
                      // fontSize: 13,
                      // letterSpacing: 1.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 20,
              ),
              Flexible(
                child: isload
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            for (var i = 0; i < list_culte.length; i++)
                              Container(
                                  // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                  margin: EdgeInsets.symmetric(
                                      vertical: 7, horizontal: 17),
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            offset: Offset(0, 0),
                                            blurRadius: 5,
                                            color: Colors.grey[300]!)
                                      ],
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(7)),
                                  width: double.infinity,
                                  child: ExpansionTile(
                                    //minVerticalPadding: 15,
                                    title: InkWell(
                                      onTap: () {
                                        showCupertinoModalPopup(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 4, sigmaY: 4),
                                                context: context,
                                                builder: (context) =>
                                                    AlertActionCulte(
                                                        list_culte[i]))
                                            .then((value) {
                                          if (value != null && value) {
                                            chargement();
                                          }
                                        });
                                      },
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          list_culte[i]["Titre"].toString(),
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    subtitle: Text(
                                      camelCase(DateFormat.yMMMMEEEEd('fr')
                                          .format(DateTime.parse(list_culte[i]
                                                  ["Date"]
                                              .toString()))),
                                      style: TextStyle(
                                          color: textColor().withOpacity(0.7)),
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: FlutterLinkPreview(
                                            url: list_culte[i]["Lien"]
                                                .toString(),
                                            titleStyle: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
//  SimpleUrlPreview(
//                                               elevation: 0,
//                                               siteNameStyle: TextStyle(
//                                                   color: Colors.blue,
//                                                   fontWeight: FontWeight.w600),
//                                               bgColor: Colors.green[100]!
//                                                   .withOpacity(0.5),
//                                               imageLoaderColor: Colors.red,
//                                               descriptionStyle:
//                                                   TextStyle(color: Colors.blue),
//                                               titleStyle: TextStyle(
//                                                   color: Colors.black,
//                                                   fontWeight: FontWeight.w600,
//                                                   fontSize: 15),
//                                               url: list_culte[i]["Lien"]
//                                                   .toString()),
                                        ),
                                      )
                                    ],
                                  )),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> get_color(int index) {
    List<Map<String, dynamic>> color_list = [
      {"c": Colors.red, "t": Colors.black},
      {"c": Colors.grey[800], "t": Colors.black},

      {"c": Colors.orange, "t": Colors.black},

      {"c": Colors.blueGrey, "t": Colors.black},
      {"c": Colors.green[400], "t": Colors.black},
      {"c": Colors.brown, "t": Colors.black},

      // {"c": Colors.grey[100], "t": Colors.black},
    ];

    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    return color_list[index];
  }
}

class AlertActionCulte extends StatefulWidget {
  Map<String, dynamic> map_data;
  AlertActionCulte(this.map_data);

  @override
  State<AlertActionCulte> createState() => AlertActionCulteState();
}

class AlertActionCulteState extends State<AlertActionCulte> {
  bool conf = false;
  String rest = '';
  Timer? timer;
  bool isload = false;
  Function()? click_sup = null;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      setState(() {
        click_sup = demarer_timer;
      });
    });
  }

  void demarer_timer() {
    setState(() {
      conf = true;
      rest = "( 5s )";
    });
    timer = Timer.periodic(Duration(seconds: 1), (timerr) {
      setState(() {
        rest = "( " + (5 - timerr.tick).toString() + "s )";
      });

      if (timerr.tick == 6) {
        setState(() {
          rest = "";
          timerr.cancel();
          click_sup = supression;
        });
      }
    });
    setState(() {
      click_sup = null;
    });
  }

  void supression() async {
    setState(() {
      isload = true;
    });
    var r = await exec_mysql_query(
        "DELETE from Cultes WHERE id=" + widget.map_data["id"].toString());
    if (r != null && r) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Culte Supprimé ✅")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Une erreur s'est produite ")));
    }
    setState(() {
      isload = false;
    });
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.map_data["Titre"].toString()),
      content: isload
          ? Container(
              height: MediaQuery.of(context).size.height * .4,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7)),
                  child: CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) =>
                                  AddCulte(widget.map_data)))).then((value) {
                        // chargement();
                      });
                    },
                    child: Text("Modifier"),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7)),
                  child: CupertinoDialogAction(
                    onPressed: click_sup,
                    child: Text(conf
                        ? "Confirmer la supression " + rest
                        : "Supprimer " + rest),
                    isDestructiveAction: true,
                  ),
                ),
              ],
            ),
    );
  }
}
