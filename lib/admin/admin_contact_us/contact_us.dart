import 'dart:async';
import 'dart:ui';

import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

import '../../api_operation.dart';
import 'add_link.dart';

class AdminContactUs extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  AdminContactUs(this.zoomDrawerController);

  @override
  State<AdminContactUs> createState() => _AdminContactUsState();
}

class _AdminContactUsState extends State<AdminContactUs> {
  bool isload = false;
  List<Map<String, dynamic>> list_lien = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargement();
  }

  void chargement() async {
    setState(() {
      isload = true;
    });
    var t = await select_data("SELECT * from Coordonnees ");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_lien = t;
      });
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage("Erreur", t[0]["error"].toString(), context);
    }
    setState(() {
      isload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDatalight,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.indigo,
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => AddLien({}))))
                  .then((value) {
                chargement();
              });
            },
            child: Icon(Icons.add)),
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
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: 'EGLISE ',
                style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'
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
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Flexible(
                  child: isload
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: ListView.builder(
                              itemCount: list_lien.length,
                              itemBuilder: (context, i) {
                                return InkWell(
                                  onTap: () {
                                    showCupertinoModalPopup(
                                            filter: ImageFilter.blur(
                                                sigmaX: 4, sigmaY: 4),
                                            context: context,
                                            builder: (context) =>
                                                AlertActionLien(list_lien[i]))
                                        .then((value) {
                                      if (value != null && value) {
                                        chargement();
                                      }
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 7),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: (get_color(i))['c'],
                                    ),
                                    width: double.infinity,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                      child: IntrinsicHeight(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              list_lien[i]["Nom"].toString(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: (get_color(i))['t']),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              child: Text(
                                                  list_lien[i]["Description"]
                                                      .toString(),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      // fontStyle: FontStyle.italic,
                                                      // fontFamily: "Material",
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: (get_color(i))['t']!
                                                          .withOpacity(0.8))),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ))
              //
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> get_color(int index) {
    List<Map<String, dynamic>> color_list = [
      {"c": Colors.red[100]!.withOpacity(0.5), "t": Colors.black},
      {"c": Colors.blue[100]!.withOpacity(0.5), "t": Colors.black},
      {"c": Colors.orange[100]!.withOpacity(0.5), "t": Colors.black},
      {"c": Colors.grey[100], "t": Colors.black},
    ];

    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    return color_list[index];
  }
}

class AlertActionLien extends StatefulWidget {
  Map<String, dynamic> map_data;
  AlertActionLien(this.map_data);

  @override
  State<AlertActionLien> createState() => AlertActionLienState();
}

class AlertActionLienState extends State<AlertActionLien> {
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
        "DELETE from Coordonnees WHERE id=" + widget.map_data["id"].toString());
    if (r != null && r) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lien Supprimé ✅")));
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
      title: Text(widget.map_data["Nom"].toString()),
      content: isload
          ? Container(
              height: MediaQuery.of(context).size.height * .4,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Text(
                  widget.map_data["Description"].toString(),
                  style: TextStyle(fontFamily: 'SourceSansPro'),
                ),
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
                                  AddLien(widget.map_data)))).then((value) {
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
