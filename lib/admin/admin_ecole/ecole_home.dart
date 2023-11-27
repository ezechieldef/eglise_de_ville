import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:eglise_de_ville/admin/admin_ecole/add_cours.dart';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';

// import 'article_enseignement.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:intl/intl.dart';

import 'chapitres.dart';

class AdminEcole extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  AdminEcole(this.zoomDrawerController);

  @override
  State<AdminEcole> createState() => _AdminEcoleState();
}

class _AdminEcoleState extends State<AdminEcole> {
  List<dynamic> cours_list = [];
  bool isload = false;
  String search_str = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargement();
  }

  void chargement() async {
    setState(() {
      isload = true;
      cours_list = [];
    });
    var t = await select_data(
        'SELECT * from Cours WHERE Titre LIKE "%$search_str%" OR Description LIKE "%$search_str%" ORDER BY ID DESC');
    print(t);
    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        cours_list = t;
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.pink,
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AdminAddCours({})))
                  .then((value) {
                chargement();
              });
            },
            child: Icon(Icons.add)),
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                widget.zoomDrawerController.toggle!();
              },
              icon: Icon(
                Icons.menu,
                color: Colors.cyan,
              )),
          actions: [
            IconButton(
                onPressed: () {
                  chargement();
                },
                icon: Icon(
                  CupertinoIcons.refresh_circled_solid,
                  color: Colors.grey[500],
                ))
          ],
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: 'EGLISE ',
                style: TextStyle(color: Colors.black, fontFamily: "Montserrat"),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "ECOLE : Cours Disponibles".toUpperCase(),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CupertinoSearchTextField(
                  style: TextStyle(fontFamily: "Material", fontSize: 14),
                  // backgroundColor: Colors.white,
                  placeholder: "Rechercher ...",
                  onChanged: (v) {
                    setState(() {
                      search_str = v;
                    });
                  },
                  onSubmitted: (v) {
                    setState(() {
                      search_str = v;
                    });
                    chargement();
                  },
                  // backgroundColor: Color(0xfffafafa),
                  prefixInsets: EdgeInsets.symmetric(horizontal: 15),
                  suffixInsets: EdgeInsets.symmetric(horizontal: 15),
                  // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  placeholderStyle:
                      TextStyle(fontFamily: "Material", color: Colors.grey),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  // margin: const EdgeInsets.symmetric(horizontal: 15),
                  // decoration: BoxDecoration(
                  //     color: Color(0xfffafafa),
                  //     borderRadius: BorderRadius.circular(10))
    
                  child: isload
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemBuilder: ((context, index) {
                            return Container(
                                // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 0),
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          // offset: Offset(0, 0),
                                          blurRadius: 5,
                                          color: Colors.grey[300]!)
                                    ],
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(7)),
                                width: double.infinity,
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AdminChapitres(
                                                cours_list[index])));
                                  },
                                  onLongPress: () {
                                    showCupertinoModalPopup(
                                        filter: ImageFilter.blur(
                                            sigmaX: 5, sigmaY: 5),
                                        context: context,
                                        builder: (context) {
                                          return AlertActionCours(
                                              cours_list[index]);
                                        }).then((value) {
                                      chargement();
                                    });
                                  },
                                  title: Text(
                                    cours_list[index]["Titre"].toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        cours_list[index]["Description"]
                                            .toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(7),
                                        child: true
                                            ? SizedBox(
                                                width: double.infinity,
                                                height: 175,
                                                child: get_cached_image(
                                                    cours_list[index]["Image"]
                                                        .toString()),
                                              )
                                            : Image.asset(
                                                "assets/image/bg_sky.jpg",
                                                width: double.infinity,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    4,
                                                fit: BoxFit.cover,
                                              ),
                                      )
                                    ],
                                  ),
                                ));
                          }),
                          itemCount: cours_list.length),
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
      {"c": Colors.red[300], "t": Colors.black},
      {"c": Colors.blue[300], "t": Colors.black},
      {"c": Colors.orange[300], "t": Colors.black},
      // {"c": Colors.grey[100], "t": Colors.black},
    ];

    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    return color_list[index];
  }
}

class AlertActionCours extends StatefulWidget {
  Map<String, dynamic> map_data;
  AlertActionCours(this.map_data);

  @override
  State<AlertActionCours> createState() => AlertActionCoursState();
}

class AlertActionCoursState extends State<AlertActionCours> {
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
        "DELETE from Cours WHERE id=" + widget.map_data["id"].toString());
    if (r != null && r) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Cours Supprimé ✅")));
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
                Text(
                  widget.map_data["Description"].toString(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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
                                      AdminAddCours(widget.map_data))))
                          .then((value) {
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
