import 'dart:convert';
import 'dart:io';

// import 'package:eglise_de_ville/enseignement/article_enseignement.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/enseignement/read_enseignement.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';

import '../api_operation.dart';
import '../contantes.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:intl/intl.dart';

Map<String, dynamic> get_color_p(int index) {
  List<Map<String, dynamic>> color_list = [
    {"c": Colors.red[100]!.withOpacity(0.5), "t": Colors.black},
    {"c": Colors.blue[100]!.withOpacity(0.5), "t": Colors.black},
    {"c": Colors.orange[100]!.withOpacity(0.5), "t": Colors.black},
    // {"c": Colors.grey[200], "t": Colors.black},
  ];

  while (index > color_list.length - 1) {
    index -= color_list.length;
  }
  return color_list[index];
}

class EnseignementPage extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  EnseignementPage(this.zoomDrawerController);

  @override
  State<EnseignementPage> createState() => _EnseignementPageState();
}

class _EnseignementPageState extends State<EnseignementPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> enseignment_list = [];
  bool isload = false;
  @override
  void dispose() {
    // TODO: implement dispose

    _controller!.dispose();
    _animation = null;
    super.dispose();
  }

  Future<void> chargement({String search_str = ""}) async {
    setState(() {
      isload = true;
      enseignment_list = [];
    });
    var t = await select_data(
        'SELECT * from Enseignement WHERE Titre LIKE "%$search_str%" OR Verset LIKE "%$search_str%" or contenu LIKE "%$search_str%" ORDER BY Date DESC ');
    print(t);
    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        enseignment_list = t;
      });
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        await inserer_local_list("Enseignement", enseignment_list);
      }
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage(
          "Avertissement",
          "L'accès internet est indisponible actuellement.\nIl se peut que d'autres enseignements soient déjà disponible ",
          context);
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        try {
          var t2 = await select_local_sqlite(
              'SELECT * from Enseignement WHERE Titre LIKE "%$search_str%" OR Verset LIKE "%$search_str%" or contenu LIKE "%$search_str%"  ORDER BY Date DESC',
              []);
          if (mounted)
            setState(() {
              enseignment_list = t2;
            });
        } catch (e) {
          print(e);
        }
      }
    }
    setState(() {
      isload = false;
    });

    _controller!.reset();
    _controller!.forward();
  }

  AnimationController? _controller;
  Animation<Offset>? _animation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, 5.0),
      end: const Offset(0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeIn,
    ));
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
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    color: textColor(),
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
                        color: textColor().withOpacity(.8),
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
                    style: TextStyle(
                        fontFamily: "Material",
                        fontSize: 14,
                        color: textColor()),
                    backgroundColor: themeData.brightness == Brightness.light
                        ? null
                        : Colors.white.withOpacity(.4),
                    placeholder: "Rechercher ...",
                    placeholderStyle: TextStyle(
                        fontFamily: "Material",
                        fontSize: 14,
                        color: textColor().withOpacity(.7)),
                    onSubmitted: (v) {
                      chargement(search_str: v);
                    },
                    prefixInsets: EdgeInsets.symmetric(horizontal: 15),
                    suffixInsets: EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Flexible(
                    child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: isload
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: ((context, index) {
                            var myJSON = jsonDecode(
                                enseignment_list[index]["Contenu"].toString());
                            fq.QuillController _control_doc =
                                fq.QuillController(
                                    document: fq.Document.fromJson(myJSON),
                                    selection:
                                        TextSelection.collapsed(offset: 0));
                            return SlideTransition(
                              position: _animation!,
                              child: Hero(
                                tag: enseignment_list[index]["id"].toString() +
                                    "htag",
                                flightShuttleBuilder: (
                                  BuildContext flightContext,
                                  Animation<double> animation,
                                  HeroFlightDirection flightDirection,
                                  BuildContext fromHeroContext,
                                  BuildContext toHeroContext,
                                ) {
                                  return SingleChildScrollView(
                                    child: fromHeroContext.widget,
                                  );
                                },
                                child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: get_color_p(index)["c"],
                                      // boxShadow: [
                                      //   BoxShadow(
                                      //       color: Colors.grey[300]!,
                                      //       blurRadius: 5,
                                      //       offset: Offset(0, 2))
                                      // ]
                                    ),
                                    // decoration: BoxDecoration(
                                    //     color: Colors.white,
                                    //     // image: DecorationImage(
                                    //     //     fit: BoxFit.cover,
                                    //     //     opacity: 0.35,
                                    //     //     image: AssetImage(
                                    //     //       "assets/image/bg_sky.jpg",
                                    //     //     )),
                                    //     boxShadow: [
                                    //       BoxShadow(
                                    //           color: Colors.grey[300]!,
                                    //           blurRadius: 5,
                                    //           offset: Offset(2, 4))
                                    //     ],
                                    //     borderRadius: BorderRadius.circular(8)),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 15),
                                    child: Material(
                                      type: MaterialType.transparency,
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async {
                                          // Navigator.push(
                                          //     context,
                                          //     PageRouteBuilder(
                                          //         transitionDuration:
                                          //             Duration(seconds: 1),
                                          //         pageBuilder: (_, __, ___) =>
                                          //             ReadArticleEnseignement(
                                          //                 enseignment_list[index])));
                                          print(enseignment_list[index]["Titre"]
                                              .toString());
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReadArticleEnseignement(
                                                          enseignment_list[
                                                              index]))).then(
                                              (value) {
                                            // chargement();
                                          });
                                        },
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
                                                enseignment_list[index]["Titre"]
                                                    .toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  // fontFamilyFallback: [
                                                  //   "NotoEmoji"
                                                  // ],
                                                  fontWeight: FontWeight.w600,
                                                  // color: Colors.black
                                                ),
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
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    // fontFamily: "Material",
                                                    fontSize: 13,
                                                    // fontWeight: FontWeight.w600,
                                                    color:
                                                        get_color(index)["c"]),
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
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    // fontFamily: "Material",
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: themeData.textTheme
                                                        .bodyText1!.color!
                                                        .withOpacity(0.6)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              child: Text(
                                                camelCase(DateFormat.yMMMMEEEEd(
                                                        "fr")
                                                    .format(DateTime.parse(
                                                        enseignment_list[index]
                                                                ["Date"]
                                                            .toString()))),
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
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
                                    )),
                              ),
                            );
                          }),
                          itemCount: enseignment_list.length),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> get_color(int index) {
    List<Map<String, dynamic>> color_list = [
      {"c": Colors.red[500], "t": Colors.black},
      {"c": Colors.blue[500], "t": Colors.black},
      {"c": Colors.orange[500], "t": Colors.black},

      {"c": Colors.grey[700], "t": Colors.black},
      // {"c": Colors.grey[100], "t": Colors.black},
    ];

    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    return color_list[index];
  }
}
