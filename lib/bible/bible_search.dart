import 'dart:convert';
import 'dart:ui';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:html_editor/html_editor.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

import '../../contantes.dart';
import 'bible_reading.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

class BibleSearch extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  BibleSearch(this.map_data);

  @override
  State<BibleSearch> createState() => _BibleSearchState(this.map_data);
}

class _BibleSearchState extends State<BibleSearch> {
  bool isload = false;
  Map<String, dynamic> map_data;
  _BibleSearchState(this.map_data) {
    search_controller = TextEditingController(text: map_data["Mot"].toString());
  }
  List<Map<String, dynamic>> list_verset = [];
  TextEditingController search_controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // charger_verset();
  }

  void charger_verset() async {
    if (search_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Saisie invalide")));
      return;
    }
    setState(() {
      isload = true;
    });
    var t_name = map_data["Version"].toString();
    var t = await select_local_sqlite_bible(
        "SELECT *, (SELECT count(DISTINCT Chapitre) from $t_name WHERE Livre=D.Livre ) MaxChapitre from $t_name D, Livres L  WHERE L.id=D.Livre AND D.Contenu LIKE '%" +
            search_controller.text.replaceAll(" ", "%").replaceAll("'", "%") +
            "%'  COLLATE NOACCENTS",
        []);
    setState(() {
      list_verset = dupliquer(t);
    });

    setState(() {
      isload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          // backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            elevation: 1,
            // backgroundColor: Colors.white,
            leading: IconButton(
                onPressed: () {
                  exitloading(context);
                },
                icon: Icon(
                  CupertinoIcons.chevron_left_circle_fill,
                  color: CupertinoColors.systemRed,
                )),
            title: CupertinoSearchTextField(
              controller: search_controller,
              // backgroundColor: Colors.grey[200],
              style: TextStyle(
                  fontFamily: "Material",
                  fontSize: 14,
                  color: isDark() ? Colors.white : Colors.black),
              // backgroundColor: Colors.white,
              placeholder: "Rechercher un passage ",
              onSubmitted: (v) {
                setState(() {
                  map_data.update("Mot", (value) => v);
                });
                charger_verset();
              },
              prefixInsets: EdgeInsets.symmetric(horizontal: 15),
              suffixInsets: EdgeInsets.symmetric(horizontal: 15),

              // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              placeholderStyle:
                  TextStyle(fontFamily: "Material", color: Colors.grey),
            ),
          ),
          body: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 5),
              // color: Colors.yellow,
              child: isload
                  ? Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : list_verset.isEmpty
                      ? Column(
                          children: [
                            SizedBox(
                              height: 25,
                            ),
                            Text("Aucune correspondances : " +
                                search_controller.text),
                            SizedBox(
                              height: 15,
                            ),
                            Flexible(
                              child: LottieBuilder.asset(
                                  "assets/lotties/lf20_n2m0isqh.json"),
                            ),
                          ],
                        )
                      : ListView.separated(
                          itemCount: list_verset.length,
                          separatorBuilder: (c, i) {
                            return Divider(
                              indent: 10,
                              endIndent: 10,
                            );
                          },
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ReadCharpenterBible({
                                              "Table": map_data["Version"]
                                                  .toString(),
                                              "Version": map_data["VersionName"]
                                                  .toString(),
                                              "LibLivre": list_verset[index]
                                                      ["Libele"]
                                                  .toString(),
                                              "Livre": list_verset[index]
                                                  ["Livre"],
                                              "Chapitre": list_verset[index]
                                                  ["Chapitre"],
                                              "MaxChapitre": list_verset[index]
                                                  ["MaxChapitre"],
                                              "Verset": list_verset[index]
                                                  ["Verset"]
                                            })));
                              },
                              child: Container(
                                color: map_data["Verset"] ==
                                        list_verset[index]["Verset"]
                                    ? Colors.grey[100]
                                    : Colors.transparent,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          list_verset[index]["Libele"]
                                                  .toString() +
                                              " " +
                                              list_verset[index]["Chapitre"]
                                                  .toString() +
                                              " :  " +
                                              list_verset[index]["Verset"]
                                                  .toString(),
                                          style: TextStyle(
                                              color:
                                                  CupertinoColors.activeGreen,
                                              fontSize: 17,
                                              // fontFamily: "Awake",
                                              // fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                        list_verset[index]["Contenu"]
                                            .toString(),
                                      ),
                                      // RichText(
                                      //     text: TextSpan(
                                      //         text:
                                      //             list_verset[index]["Verset"].toString() +
                                      //                 " ",
                                      //        ,
                                      //         children: [
                                      //       TextSpan(
                                      //         text:
                                      //             list_verset[index]["Contenu"].toString(),
                                      //         style: TextStyle(
                                      //             color: Colors.black54,
                                      //             fontSize: 15,
                                      //             fontFamily: "SourceSansPro",
                                      //             fontStyle: FontStyle.normal,
                                      //             fontWeight: FontWeight.w400),
                                      //       )
                                      //     ])),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }))),
    );
  }

  Widget get_col_textfield(String titre, {int mini = 1, int maxi = 1}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre),
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4)),
            child: TextFormField(
              initialValue: map_data[titre].toString(),
              onChanged: (v) {
                setState(() {
                  map_data.update(titre, (value) => v);
                });
              },
              minLines: mini,
              maxLines: maxi,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          )
        ],
      ),
    );
  }
}
