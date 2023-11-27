import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:eglise_de_ville/admin/admin_programme/add_pgr.dart';
import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/programmes/liste_pg.dart';
import 'package:eglise_de_ville/programmes/vue_calendrier.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:intl/intl.dart';

class WeekProgramme extends StatefulWidget {
  @override
  State<WeekProgramme> createState() => _WeekProgrammeState();
}

class _WeekProgrammeState extends State<WeekProgramme> {
  List<Map<String, dynamic>> list_progr = [];
  bool isload = false;
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
    var t = await select_data("SELECT * from Programme ");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_progr = filtrer_ancien(t);
      });
      inserer_local_list("Programme", t);
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      // showMessage("Avertissement", t[0]["error"].toString(), context);
      showMessage("Avertissement", internet_off_str, context);
      try {
        var tr = await select_local_sqlite("SELECT * from Programme ", []);
        setState(() {
          list_progr = filtrer_ancien(tr);
        });
      } catch (e) {}
    }
    setState(() {
      isload = false;
    });
  }

  List<Map<String, dynamic>> filtrer_ancien(List<Map<String, dynamic>> old) {
    List<Map<String, dynamic>> l = [];
    for (var i = 0; i < old.length; i++) {
      if (old[i]["Repetition"].toString() == "-") {
        DateTime dt = DateTime.parse(old[i]["Date"].toString());
        if (dt.isBefore(DateTime.now())) {
          print("detect --- ");
          continue;
        }
      } else if (old[i]["Repetition"].toString() == "+") {
        DateTime dt = DateTime.parse(old[i]["Date"].toString());
        if (dt.year == DateTime.now().year && dt.month > DateTime.now().month) {
          continue;
        }
      }

      l.add(old[i]);
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Flexible(
              child: isload
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: list_progr.length,
                      itemBuilder: (context, i) {
                        return InkWell(
                          onTap: () {
                            showCupertinoModalPopup(
                                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                context: context,
                                builder: (context) =>
                                    AlertActionPgrm(list_progr[i])).then(
                                (value) {
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
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              list_progr[i]["Titre"].toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              child: Text(
                                                  list_progr[i]["Description"]
                                                      .toString(),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      // fontStyle: FontStyle.italic,
                                                      fontFamily: "Material",
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: themeData.textTheme
                                                          .bodyText1!.color!
                                                          .withOpacity(0.8))),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Icon(CupertinoIcons.clock_fill,
                                                    color: themeData.textTheme
                                                        .bodyText1!.color!
                                                        .withOpacity(0.8),
                                                    size: 20),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Flexible(
                                                  child: IntrinsicHeight(
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: Column(
                                                        children: [
                                                          Text(date_ops(
                                                              list_progr[i])),
                                                          Text(
                                                              formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.parse("1990-01-01 " +
                                                                      list_progr[i]
                                                                              [
                                                                              "Heure_Debut"]
                                                                          .toString()))) +
                                                                  " - " +
                                                                  formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.parse("1990-01-01 " +
                                                                      list_progr[i]
                                                                              [
                                                                              "Heure_Fin"]
                                                                          .toString()))),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    "Material",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    VerticalDivider(
                                        color: (get_color(i))['t']!
                                            .withOpacity(0.2)),
                                    RotatedBox(
                                      quarterTurns: 3,
                                      child: Text(
                                        list_progr[i]["Personne_Cible"]
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: "Material",
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }))
          //
        ],
      ),
    );
  }

  Map<String, dynamic> get_color(int index) {
    List<Map<String, dynamic>> color_list = [
      {"c": Colors.red[100]!.withOpacity(0.5), "t": Colors.black},
      {"c": Colors.blue[100]!.withOpacity(0.5), "t": Colors.black},
      {"c": Colors.orange[100]!.withOpacity(0.5), "t": Colors.black},
      // {"c": Colors.grey[100], "t": Colors.black},
    ];

    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    return color_list[index];
  }

  // Map<String, dynamic> get_color(int pos, int index) {
  //   List<Map<String, dynamic>> color_list = [
  //     {"c": Colors.blue[300], "f": Colors.blue[600], "t": true},
  //     {"c": Colors.red[300], "f": Colors.red[600], "t": true},
  //     {
  //       "c": Color.fromRGBO(69, 229, 69, 1),
  //       "f": Color.fromARGB(255, 47, 185, 47),
  //       "t": true
  //     },
  //   ];
  //   var fff = {"c": Colors.grey[200]!, "t": false};
  //   while (index > color_list.length - 1) {
  //     index -= color_list.length;
  //   }
  //   Map<String, dynamic> m = {
  //     "c": Colors.grey[200]!,
  //     "t": false,
  //     "f": Colors.grey[300]
  //   };
  //   if (pos == 0) {
  //     m = color_list[index];
  //   }

  //   return m;
  // }
}

String date_ops(Map<String, dynamic> data) {
  DateTime dt = DateTime.parse(data["Date"].toString());
  switch (data["Repetition"]) {
    case "-":
      return camelCase(DateFormat.yMMMMEEEEd("fr").format(dt));
    case "+":
      return "Tous les " +
          camelCase(DateFormat.EEEE("fr").format(dt)) +
          " de " +
          camelCase(DateFormat.yMMM("fr").format(dt));
    case "*":
      return "Tous les " + camelCase(DateFormat.EEEE("fr").format(dt));
    default:
      return "";
  }
}

class AlertActionPgrm extends StatefulWidget {
  Map<String, dynamic> map_data;
  AlertActionPgrm(this.map_data);

  @override
  State<AlertActionPgrm> createState() => AlertActionPgrmState();
}

class AlertActionPgrmState extends State<AlertActionPgrm> {
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
        "DELETE from Programme WHERE id=" + widget.map_data["id"].toString());
    if (r != null && r) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Programme Supprimé ✅")));
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
                Text(widget.map_data["Description"]),
                SizedBox(
                  height: 10,
                ),
                Text(date_ops(widget.map_data).toUpperCase()),
                SizedBox(
                  height: 10,
                ),
                Text(formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.parse(
                        "1990-01-01 " +
                            widget.map_data["Heure_Debut"].toString()))) +
                    " - " +
                    formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.parse(
                        "1990-01-01 " +
                            widget.map_data["Heure_Fin"].toString())))),
              ],
            ),
    );
  }
}
