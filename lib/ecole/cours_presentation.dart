import 'dart:convert';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/ecole/lecture_cours.dart';
import 'package:eglise_de_ville/profile_view.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:eglise_de_ville/user_login/authpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:html_editor/html_editor.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../contantes.dart';
import '../contante_var2.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

class PresentationCours extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  PresentationCours(this.map_data);

  @override
  State<PresentationCours> createState() =>
      _PresentationCoursState(this.map_data);
}

class _PresentationCoursState extends State<PresentationCours> {
  bool isload = false;
  Map<String, dynamic> map_data;
  _PresentationCoursState(this.map_data);
  List<Map<String, dynamic>> list_chapitre = [];
  int chapitre_cours = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    charger_chapitres();
  }

  void charger_chapitres() async {
    setState(() {
      isload = true;
      list_chapitre = [];
    });
    var t = await select_data(
        "SELECT C.* , (select id from Quiz  where id_chapitre=C.id Limit 1) quiz,"
                "(select CQ.Avis from Quiz QQ, composer_quiz CQ WHERE QQ.id_chapitre=C.id AND QQ.id=CQ.quiz_id AND CQ.user_id='" +
            connected_user["id"].toString() +
            "' ORDER BY CQ.id DESC LIMIT 1 ) Avis "
                "from Chapitres C WHERE id_cours='" +
            map_data["id"].toString() +
            "' ORDER BY num_chapitre ASC;");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_chapitre = t;
      });
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage("Erreur", t[0]["error"].toString(), context);
    }
    setState(() {
      isload = false;
    });
    verouilage();
  }

  void verouilage() {
    if (list_chapitre.length > 1) {}
    for (var i = 1; i < list_chapitre.length; i++) {
      if (list_chapitre[i - 1]["Avis"].toString() != "SUCCESS") {
        list_chapitre[i]["lock"] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xfffafafa),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black26,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                exitloading(context);
              },
              icon: Icon(
                CupertinoIcons.chevron_left_circle_fill,
                color: CupertinoColors.white,
              )),
          centerTitle: true,
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: 'EGLISE ',
                style: TextStyle(shadows: [
                  Shadow(
                      color: Colors.grey[800]!,
                      blurRadius: 2,
                      offset: Offset(1, 1))
                ], color: Colors.white, fontFamily: "Montserrat"),
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
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(
                        map_data["Image"].toString()),
                    fit: BoxFit.cover)),
            padding: EdgeInsets.symmetric(vertical: 0),
            child: Container(
              color: Colors.black26,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Column(
                  children: [
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: AppBar().preferredSize.height * 1.7,
                                ),

                                Theme(
                                  data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    tilePadding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    title: Text(
                                      map_data["Titre"].toString(),
                                      // textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                              shadows: [
                                            Shadow(
                                                color: Colors.grey[800]!,
                                                blurRadius: 2,
                                                offset: Offset(1, 1))
                                          ],
                                              color: Colors.white,
                                              fontFamily: "Montserrat"),
                                    ),
                                    subtitle: Text(
                                      "Tapez pour voir la description",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                        shadows: [
                                          Shadow(
                                              color: Colors.grey[800]!,
                                              blurRadius: 2,
                                              offset: Offset(1, 1))
                                        ],
                                        color: Colors.white,
                                        // fontFamily: "Montserrat"
                                      ),
                                    ),
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        map_data["Description"].toString(),
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          color: Colors.white,
                                          // fontFamily: "",
                                          shadows: [
                                            Shadow(
                                                color: Colors.grey[800]!,
                                                blurRadius: 2,
                                                offset: Offset(1, 1)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  height: 10,
                                ),

                                SizedBox(
                                  width: double.infinity,
                                  child: RichText(
                                      textAlign: TextAlign.end,
                                      text: TextSpan(
                                          text: "Durée : ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .copyWith(
                                                  fontSize: 16,
                                                  shadows: [
                                                    Shadow(
                                                        color:
                                                            Colors.grey[800]!,
                                                        blurRadius: 2,
                                                        offset: Offset(1, 1))
                                                  ],
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600
                                                  // fontFamily: "Montserrat"
                                                  ),
                                          children: [
                                            TextSpan(
                                                text: map_data["Durée"]
                                                        .toString() +
                                                    " Jours",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w300))
                                          ])),
                                ),
                                ProfileView(),

                                Divider(
                                  height: 25,
                                  indent: 0,
                                  endIndent: 0,
                                  color: Colors.white38,
                                ),
                                // SizedBox(
                                //   height: 15,
                                // ),

                                Text(
                                  "Chapitres :",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                    shadows: [
                                      Shadow(
                                          color: Colors.grey[800]!,
                                          blurRadius: 2,
                                          offset: Offset(1, 1))
                                    ],
                                    color: Colors.white,
                                    //  fontFamily: "Montserrat"
                                  ),
                                ),
                                isload
                                    ? SizedBox(
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .5,
                                        child: Center(
                                            child: CircularProgressIndicator()))
                                    : list_chapitre.isEmpty
                                        ? SizedBox(
                                            width: double.infinity,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .5,
                                            child: Center(
                                                child: Text(
                                                    "Aucun chapitre n'a encore été trouvé, réessayer plus tard svp !!",
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6!
                                                        .copyWith(
                                                          color: Colors.white,
                                                        ))))
                                        : SizedBox(
                                            height: 10,
                                          ),
                                SizedBox(
                                  height: 10,
                                ),
                                // SizedBox(
                                //     width: double.infinity,
                                //     // padding: EdgeInsets.symmetric(horizontal: 10),
                                //     child: SingleChildScrollView(
                                //       scrollDirection: Axis.horizontal,
                                //       child: Row(
                                //         children: [
                                //           for (var i = 0; i < 15; i++)
                                //             InkWell(
                                //               onTap: () {
                                //                 // changer_edition(i);
                                //               },
                                //               child: Container(
                                //                 margin: EdgeInsets.symmetric(
                                //                     horizontal: 5),
                                //                 padding: EdgeInsets.symmetric(
                                //                     horizontal: 12, vertical: 7),
                                //                 decoration: BoxDecoration(
                                //                   // boxShadow: [
                                //                   //   BoxShadow(
                                //                   //       color: Colors.grey[200]!,
                                //                   //       blurRadius: 2)
                                //                   // ],
                                //                   borderRadius:
                                //                       BorderRadius.circular(4),
                                //                   color: 0 == i
                                //                       ? CupertinoColors
                                //                           .activeGreen
                                //                       : Colors.white,
                                //                 ),
                                //                 child: IntrinsicHeight(
                                //                   child: Column(
                                //                     children: [
                                //                       Text(
                                //                         (i + 1).toString(),
                                //                         style: TextStyle(
                                //                           color: 0 == i
                                //                               ? CupertinoColors
                                //                                   .white
                                //                               : Colors.black,
                                //                         ),
                                //                       ),
                                //                       SizedBox(
                                //                         height: 5,
                                //                       ),
                                //                       Text(
                                //                         (i + 1).toString() +
                                //                             " Juin",
                                //                         style: TextStyle(
                                //                           color: 0 == i
                                //                               ? CupertinoColors
                                //                                   .white
                                //                               : Colors.black,
                                //                         ),
                                //                       ),
                                //                     ],
                                //                   ),
                                //                 ),
                                //               ),
                                //             )
                                //         ],
                                //       ),
                                //     )),
                                // SizedBox(
                                //   height: 20,
                                // ),
                                for (var i = 0; i < list_chapitre.length; i++)
                                  Container(
                                    // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                    margin: EdgeInsets.symmetric(
                                        vertical: 7, horizontal: 0),
                                    decoration: BoxDecoration(
                                        color: i == chapitre_cours
                                            ? CupertinoColors.activeGreen
                                            : Colors.white30,
                                        borderRadius: BorderRadius.circular(7)),
                                    width: double.infinity,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent),
                                      child: ListTile(
                                        onTap: () {
                                          setState(() {
                                            chapitre_cours = i;
                                          });
                                        },
                                        minLeadingWidth: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .fontSize,
                                        leading: Text(
                                          (list_chapitre[i]['num_chapitre']
                                                  .toString())
                                              .toString(),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .copyWith(
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                  color: Colors.grey[800]!,
                                                  blurRadius: 2,
                                                  offset: Offset(1, 1))
                                            ],
                                          ),
                                        ),
                                        // childrenPadding: EdgeInsets.symmetric(
                                        //     horizontal: 15, vertical: 0),
                                        trailing: list_chapitre[i]["Avis"]
                                                    .toString() ==
                                                "SUCCESS"
                                            ? Icon(
                                                CupertinoIcons
                                                    .checkmark_seal_fill,
                                                color: Colors.white,
                                              )
                                            : true
                                                ? list_chapitre[i]["lock"] ==
                                                        true
                                                    ? Icon(
                                                        CupertinoIcons.lock,
                                                        color: Colors.white,
                                                      )
                                                    : SizedBox()
                                                : FutureBuilder<
                                                        List<
                                                            Map<String,
                                                                dynamic>>>(
                                                    future: select_local_sqlite(
                                                        "SELECT * from chapitre_lu WHERE id_chapitre=" +
                                                            list_chapitre[i]
                                                                    ["id"]
                                                                .toString(),
                                                        []),
                                                    builder: (context, fun) {
                                                      print("zatabala $fun " +
                                                          list_chapitre[i]["id"]
                                                              .toString());
                                                      if (fun.hasData &&
                                                          fun.data!.length !=
                                                              0) {
                                                        return Icon(
                                                          CupertinoIcons
                                                              .text_badge_checkmark,
                                                          color: Colors.white,
                                                        );
                                                      } else {
                                                        return chapitre_cours ==
                                                                i
                                                            ? Icon(
                                                                CupertinoIcons
                                                                    .play_fill,
                                                                color: Colors
                                                                    .white,
                                                              )
                                                            : SizedBox();
                                                      }
                                                    }),
                                        // Icon(
                                        //     CupertinoIcons
                                        //         .text_badge_checkmark,
                                        //     color: Colors.white,
                                        //   ),
                                        title: Text(
                                          list_chapitre[i]['Titre'].toString(),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            shadows: [
                                              Shadow(
                                                  color: Colors.grey[800]!,
                                                  blurRadius: 2,
                                                  offset: Offset(1, 1))
                                            ],
                                            color: Colors.white,
                                            //  fontFamily: "Montserrat"
                                          ),
                                        ),
                                        // subtitle: Text("Jeudi 1 Mai",
                                        //     style: Theme.of(context)
                                        //         .textTheme
                                        //         .bodyMedium!
                                        //         .copyWith(
                                        //           color: Colors.white,
                                        //         ))
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: isload
                          ? null
                          : () async {
                              if (await checkLogin(context)) {
                                if (list_chapitre[chapitre_cours]["lock"] ==
                                    true) {
                                  showMessageJolie(
                                      "Info",
                                      "Vous ne pouvez pas encore lire ce chapitre. Veuillez procéder étape par étape svp !",
                                      Colors.orange,
                                      context);
                                  return;
                                }
                                var t = dupliquer([map_data]).first;
                                list_chapitre[chapitre_cours]
                                    .forEach((key, value) {
                                  t["ch_" + key] = value;
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LectureCours(t))).then((value) {
                                  charger_chapitres();
                                });
                              }
                            },
                      child: Container(
                        // width: double.infinity,
                        alignment: Alignment.center,
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeGreen,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          chapitre_cours == 0 ? "Démarer" : "Lecture",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )));
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
