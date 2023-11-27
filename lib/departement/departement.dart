import 'package:eglise_de_ville/contante_var2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

import '../api_operation.dart';
import '../contantes.dart';

class DepartementPage extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  DepartementPage(this.zoomDrawerController);

  @override
  State<DepartementPage> createState() => _DepartementPageState();
}

class _DepartementPageState extends State<DepartementPage> {
  List<Map<String, dynamic>> list_depart = [];
  bool isload = false;
  void chargement({String search = ""}) async {
    setState(() {
      isload = true;
      list_depart = [];
    });

    var t = await select_data(
        "SELECT * from Departement WHERE Titre LIKE '%$search%' ");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_depart = t;
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
      await ul.launchUrl(
          Uri.parse(list_depart[index]["lien_rejoindre"].toString()),
          mode: ul.LaunchMode.externalNonBrowserApplication);
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
      data: themeData,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                child: Text(
                  "Départements".toUpperCase(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: textColor().withOpacity(.7),
                      // fontSize: 13,
                      // letterSpacing: 1.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                child: CupertinoSearchTextField(
                  style: TextStyle(
                      fontFamily: "Material", fontSize: 14, color: textColor()),
                  // backgroundColor: Colors.white,
                  placeholder: "Rechercher ...",
                  onSubmitted: (v) {
                    chargement(search: v);
                  },
                  prefixInsets: EdgeInsets.symmetric(horizontal: 15),
                  suffixInsets: EdgeInsets.symmetric(horizontal: 15),
                  // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  placeholderStyle:
                      TextStyle(fontFamily: "Material", color: Colors.grey),
                ),
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
                            for (var i = 0; i < list_depart.length; i++)
                              Container(
                                // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                margin: EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 25),
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      isDark()
                                          ? BoxShadow()
                                          : BoxShadow(
                                              offset: Offset(0, 0),
                                              blurRadius: 5,
                                              color: Colors.grey[300]!)
                                    ],
                                    color: isDark()
                                        ? Colors.white.withOpacity(.4)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(7)),
                                width: double.infinity,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    childrenPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    leading: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: get_color(i)["c"],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Icon(
                                        Icons.back_hand,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    title: Text(
                                      list_depart[i]["Titre"].toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      list_depart[i]["Membres"].toString() +
                                          " Personne(s)",
                                      style: TextStyle(color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    children: [
                                      Container(
                                          width: double.infinity,
                                          child: Text(list_depart[i]
                                                  ["Description"]
                                              .toString())),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: MaterialButton(
                                          color: Colors.red,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            btn_rejoindre(i);
                                          },
                                          minWidth: double.infinity,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Rejoindre".toUpperCase(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
