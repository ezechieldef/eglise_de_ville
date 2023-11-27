import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:eglise_de_ville/admin/enseignement/add_enseignement.dart';
import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';

// import 'article_enseignement.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:intl/intl.dart';

class AdminEnseignement extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  AdminEnseignement(this.zoomDrawerController);

  @override
  State<AdminEnseignement> createState() => _AdminEnseignementState();
}

class _AdminEnseignementState extends State<AdminEnseignement> {
  List<dynamic> enseignment_list = [];
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
      enseignment_list = [];
    });
    var t = await select_data(
        'SELECT * from Enseignement WHERE Titre LIKE "%$search_str%" OR verset LIKE "%$search_str%" or contenu LIKE "%$search_str%" ORDER BY Date DESC');
    print(t);
    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        enseignment_list = t;
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
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminAddEnseignemnt({})))
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
                  color: Colors.red,
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
            title: Text(
              "Eglise de ville".toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontFamily: "Montserrat",
                color: Colors.red[600]!,
                // color: Colors.grey[700]
              ),
            )),
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
                  "Enseignements".toUpperCase(),
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
                            var myJSON = jsonDecode(
                                enseignment_list[index]["Contenu"].toString());
                            fq.QuillController _control_doc = fq.QuillController(
                                document: fq.Document.fromJson(myJSON),
                                selection: TextSelection.collapsed(offset: 0));
                            return Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    // image: DecorationImage(
                                    //     fit: BoxFit.cover,
                                    //     opacity: 0.2,
                                    //     image: AssetImage(
                                    //       "assets/image/img1.png",
                                    //     )),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey[300]!,
                                          blurRadius: 5,
                                          offset: Offset(2, 4))
                                    ],
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.only(right: 10),
                                margin: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 15),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: InkWell(
                                    onTap: () {
                                      showCupertinoModalPopup(
                                          filter: ImageFilter.blur(
                                              sigmaX: 4, sigmaY: 4),
                                          context: context,
                                          builder: (context) => AlertActionEns(
                                              enseignment_list[index])).then(
                                          (value) {
                                        if (value != null && value) {
                                          chargement();
                                        }
                                      });
                                    },
                                    child: IntrinsicHeight(
                                        child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Container(
                                        //   width: 5,
                                        //   margin: EdgeInsets.symmetric(
                                        //       horizontal: 0, vertical: 0),
                                        //   decoration: BoxDecoration(
                                        //       color: get_color(
                                        //           index)["c"] // Colors.grey[300],
                                        //       // borderRadius: BorderRadius.circular(5)
                                        //       ),
                                        // ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                          child: Container(
                                            width: double.infinity,
                                            // color: Colors.yellow,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 6,
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  child: Text(
                                                    enseignment_list[index]
                                                            ["Titre"]
                                                        .toString(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily: 'Material',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  child: Text(
                                                    enseignment_list[index]
                                                            ["Verset"]
                                                        .toString(),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.right,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        // fontFamily: "Material",
                                                        fontSize: 13,
                                                        // fontWeight: FontWeight.w600,
                                                        color: get_color(
                                                            index)["c"]),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  child: Text(
                                                    _control_doc.document
                                                        .toPlainText()
                                                        .toString(),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        // fontFamily: "Material",
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.grey[600]),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  child: Text(
                                                    camelCase(DateFormat
                                                            .yMMMMEEEEd("fr")
                                                        .format(DateTime.parse(
                                                            enseignment_list[
                                                                    index]["Date"]
                                                                .toString()))),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        // fontFamily: "Material",
                                                        fontSize: 12,
                                                        // fontStyle: FontStyle.italic,
                                                        // fontWeight: FontWeight.w600,
                                                        color: Colors.grey[400]),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                  ),
                                ));
                          }),
                          itemCount: enseignment_list.length),
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

class AlertActionEns extends StatefulWidget {
  Map<String, dynamic> map_data;
  AlertActionEns(this.map_data);

  @override
  State<AlertActionEns> createState() => AlertActionEnsState();
}

class AlertActionEnsState extends State<AlertActionEns> {
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
    var r = await exec_mysql_query("DELETE from Enseignement WHERE id=" +
        widget.map_data["id"].toString());
    if (r != null && r) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enseignement Supprimé ✅")));
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
                Text(widget.map_data["Verset"].toString()),
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
                                      AdminAddEnseignemnt(widget.map_data))))
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
