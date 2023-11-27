import 'package:eglise_de_ville/ecole/cours_presentation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

import '../api_operation.dart';
import '../contante_var2.dart';
import '../contantes.dart';
import 'package:intl/intl.dart' as intl;

import '../sqlite_folder/principal.dart';

class EcoleHome extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  EcoleHome(this.zoomDrawerController);

  @override
  State<EcoleHome> createState() => _EcoleHomeState();
}

class _EcoleHomeState extends State<EcoleHome> {
  List<Map<String, dynamic>> list_cours = [];
  bool isload = false;
  Future<void> chargement({String search = ""}) async {
    if (mounted)
      setState(() {
        isload = true;
        list_cours = [];
      });

    var t = await select_data(
        "SELECT * from Cours WHERE Titre LIKE '%$search%' ORDER BY id DESC");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      if (mounted)
        setState(() {
          list_cours = t;
        });
      inserer_local_list("Cours", t);
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      // showMessage("Erreur", t[0]["error"].toString(), context);
      showMessage("Avertissement", internet_off_str, context);
      try {
        var t2 = await select_local_sqlite(
            "SELECT * from Cours WHERE Titre LIKE '%$search%' ORDER BY id DESC",
            []);
        if (mounted)
          setState(() {
            list_cours = t2;
          });
      } catch (e) {}
    }
    if (mounted)
      setState(() {
        isload = false;
      });
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
      data: themeData,
      child: RefreshIndicator(
        onRefresh: chargement,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            iconTheme: themeData.iconTheme,
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
            // margin: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Text(
                    "Ecole : Cours Disponible".toUpperCase(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: textColor().withOpacity(0.9),
                        // fontSize: 13,
                        // letterSpacing: 1.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: CupertinoSearchTextField(
                    style:
                        TextStyle(fontFamily: "Material", color: textColor()),
                    backgroundColor: themeData.brightness == Brightness.light
                        ? null
                        : Colors.white.withOpacity(.4),
                    placeholder: "Rechercher ...",
                    placeholderStyle: TextStyle(
                        fontFamily: "Material",
                        color: textColor().withOpacity(.7)),
                    onSubmitted: (v) {
                      chargement(search: v);
                    },
                    prefixInsets: EdgeInsets.symmetric(horizontal: 15),
                    suffixInsets: EdgeInsets.symmetric(horizontal: 15),
                    // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Flexible(
                  child: isload
                      ? Center(
                          child: CupertinoActivityIndicator(),
                        )
                      : SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              for (var i = 0; i < list_cours.length; i++)
                                Container(
                                    // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 0),
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          themeData.brightness ==
                                                  Brightness.light
                                              ? BoxShadow(
                                                  // offset: Offset(0, 0),
                                                  blurRadius: 5,
                                                  color: Colors.grey[300]!)
                                              : BoxShadow()
                                        ],
                                        color: themeData.brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.white.withOpacity(.4),
                                        borderRadius: BorderRadius.circular(7)),
                                    width: double.infinity,
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            routeTransition(PresentationCours(
                                                list_cours[i])));
                                      },
                                      title: Text(
                                        list_cours[i]["Titre"].toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            list_cours[i]["Description"]
                                                .toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 175,
                                                child: get_cached_image(
                                                  list_cours[i]["Image"]
                                                      .toString(),
                                                ),
                                              ))
                                        ],
                                      ),
                                    )),
                            ],
                          ),
                        ),
                ),
              ],
            ),
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
