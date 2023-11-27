import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
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
import 'package:dots_indicator/dots_indicator.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

class QuizHome extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  QuizHome(this.map_data);

  @override
  State<QuizHome> createState() => _QuizHomeState(this.map_data);
}

class _QuizHomeState extends State<QuizHome> {
  bool isload = false;
  Map<String, dynamic> map_data;
  _QuizHomeState(this.map_data);
  List<Map<String, dynamic>> list_questions = [];
  List<Map<String, dynamic>> list_questions_originale = [];
  int current_question = 0;
  ScrollController scontroller = ScrollController();
  CarouselController ccontroller = CarouselController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    list_questions_originale = convert_dynamic_list_to_list_of_map(
        jsonDecode(map_data["quiz"]["questions"].toString()));
    list_questions = convert_dynamic_list_to_list_of_map(
        jsonDecode(map_data["quiz"]["questions"].toString()));
    list_questions.forEach((element) {
      element["reponses"].shuffle();
      element["reponse"] = null;
    });
  }

  void charger_verset() async {
    setState(() {
      isload = true;
    });

    setState(() {
      isload = false;
    });
  }

  bool relire = false;
  double donner_note() {
    int bne_rep = 0;
    for (var i = 0; i < list_questions.length; i++) {
      if (list_questions[i]["reponse"] ==
          list_questions_originale[i]["reponses"][0]) {
        bne_rep++;
      }
    }
    return (bne_rep * 100) / list_questions.length;
  }

  void poster_reponse() async {
    print(donner_note().round());

    Map<String, dynamic> map_rep = {
      "user_id": connected_user["id"],
      "quiz_id": map_data["quiz"]["id"],
      "Details": jsonEncode(list_questions),
      "Note": donner_note().round(),
      "Avis": donner_note().round() >= map_data["quiz"]["reussite"]
          ? "SUCCESS"
          : "ECHEC"
    };

    showloading(context);

    Map<String, dynamic> conn = await insert_data(map_rep, "composer_quiz");

    if (conn["status"] != "OK") {
      exitloading(context);
      showMessage(
          "Désolé",
          "Une erreur s'est produite, veuillez réessayer plus tard svp",
          context);
      //showMessage("Désolé", conn["message"].toString(), context);

      return;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Réponses Enregsitré ✅")));
    }

    exitloading(context);
    exitloading(context);
    showCupertinoModalPopup(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        barrierDismissible: false,
        context: context,
        builder: (c) => Theme(
              data: themeData,
              child: AlertDialog(
                scrollable: true,
                elevation: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        map_rep["Avis"] == "SUCCESS"
                            ? "Félicitation"
                            : "Désolé",
                        style: TextStyle(
                            color: CupertinoColors.activeGreen,
                            fontSize: 16,
                            fontFamily: "Circular",
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600)),
                    Text(map_rep["Note"].toString() + " / 100",
                        style: TextStyle(
                            // color: CupertinoColors.black,
                            fontSize: 16,
                            fontFamily: "Circular",
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                actions: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: MaterialButton(
                      color: CupertinoColors.activeGreen,
                      elevation: 0,
                      textColor: Colors.white,
                      onPressed: () {
                        exitloading(context);
                      },
                      minWidth: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                      child: Text(
                        map_rep["Avis"] == "SUCCESS"
                            ? "Chapitre Suivant"
                            : "Relire le chapitre",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
                actionsPadding: EdgeInsets.zero,
                buttonPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                contentPadding:
                    EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 0),
                content: IntrinsicHeight(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        map_rep["Avis"] != "SUCCESS"
                            ? RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                    style: TextStyle(
                                        // color: Colors.black54,
                                        fontFamily: "Circular",
                                        fontWeight: FontWeight.w600),
                                    children: [
                                      TextSpan(
                                        text: "Note Requise : ",
                                      ),
                                      TextSpan(
                                          style: TextStyle(
                                              color: Colors.orange,
                                              fontFamily: "Circular"),
                                          text: map_data["quiz"]["reussite"]
                                                  .toString() +
                                              " / 100 "),
                                      TextSpan(
                                          text:
                                              ". Nous vous conseillons de relire le chapitre, puis repasser le test prochainement.")
                                    ]))
                            : SizedBox(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: LottieBuilder.asset(
                            map_rep["Avis"] == "SUCCESS"
                                ? "assets/lotties/lf20_kfl4ksd9.json"
                                : "assets/lotties/lf20_kyqRXF.json",
                            repeat: false,
                          ),
                        ),
                        // ClipRRect(
                        //   borderRadius: BorderRadius.circular(5),
                        //   child: MaterialButton(
                        //     color: CupertinoColors.activeGreen,
                        //     elevation: 0,
                        //     textColor: Colors.white,
                        //     onPressed: poster_reponse,
                        //     minWidth: double.infinity,
                        //     padding:
                        //         EdgeInsets.symmetric(vertical: 15, horizontal: 7),
                        //     child: Text(
                        //       map_rep["Avis"] == "SUCCESS"
                        //           ? "Chapitre Suivant"
                        //           : "Relire le chapitre",
                        //       style: TextStyle(
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ),
              ),
            )).then((value) {
      exitloading(context);
      exitloading(context);
    });
  }

  void soumettre_reponses() {
    if (!peut_soumettre(showSnack: true)) return;
    // ClipRRect(
    //                 borderRadius: BorderRadius.circular(5),
    //                 child: MaterialButton(
    //                   color: CupertinoColors.activeGreen,
    //                   elevation: 0,
    //                   textColor: Colors.white,
    //                   onPressed: poster_reponse,
    //                   minWidth: double.infinity,
    //                   padding:
    //                       EdgeInsets.symmetric(vertical: 15, horizontal: 7),
    //                   child: Text(
    //                     "Soumettre",
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.w600,
    //                     ),
    //                   ),
    //                 ),
    //               )
    showModalBottomSheet(
        context: context,
        isScrollControlled: false,
        backgroundColor: Colors.transparent,
        builder: (c) => Theme(
              data: themeData,
              child: Container(
                decoration: BoxDecoration(
                    color: isDark() ? Colors.grey[900] : Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15))),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Résumé",
                              style: TextStyle(
                                  color: textColor(),
                                  fontSize: 16,
                                  fontFamily: "Circular",
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w600)),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: MaterialButton(
                                color: Colors.grey[800],
                                elevation: 0,
                                textColor: Colors.white,
                                onPressed: poster_reponse,
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 7),
                                child: Text(
                                  "Valider",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Divider(),
                      for (var i = 0; i < list_questions.length; i++)
                        ListTile(
                          isThreeLine: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            list_questions[i]["question"].toString(),
                            style: themeData.textTheme.bodyText1,
                          ),
                          subtitle: SizedBox(
                            width: double.infinity,
                            child: Text(
                              list_questions[i]["reponse"].toString(),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: CupertinoColors.activeOrange,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ));
  }

  void repondre(int position, String reponse) {
    setState(() {
      list_questions[position].update("reponse", (value) => reponse);
    });

    ccontroller.nextPage();
  }

  bool peut_soumettre({bool showSnack = false}) {
    for (var i = 0; i < list_questions.length; i++) {
      if (list_questions[i]["reponse"] == null) {
        if (showSnack)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              content: Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 1),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5)),
                  child: true
                      ? RichText(
                          text: TextSpan(children: [
                          WidgetSpan(
                              child: Icon(
                            Icons.info_rounded,
                            color: Colors.white,
                            size: 20,
                          )),
                          TextSpan(
                              text:
                                  "  Vous n'avez pas encore répondu à toutes les questions",
                              style: TextStyle(color: Colors.white))
                        ]))
                      : Text(
                          "Vous n'avez pas encore répondu à toutes les questions"))));
        return false;
      }
    }
    return true;
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => Theme(
            data: themeData,
            child: new AlertDialog(
              title: new Text('Attention !!!'),
              content: new Text(
                  'Notez que vous ne pourrez pas recomposer tout de suite (au moins 15 minutes d\'attente) si vous abandonnez maintenant\n\nÊtes-vous sûr de vouloir quitter maintenant ?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text('Non'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: new Text('Oui'),
                ),
              ],
            ),
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Theme(
        data: themeData,
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor:
                isDark() ? Colors.black : Color.fromARGB(255, 242, 242, 242),
            extendBodyBehindAppBar: false,
            appBar: true
                ? AppBar(
                    centerTitle: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    // leading: IconButton(
                    //     onPressed: () {

                    //     },
                    //     icon: Icon(
                    //       Icons.menu,
                    //       color: Colors.red,
                    //     )),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            (current_question + 1).toString() +
                                " / " +
                                list_questions.length.toString(),
                            style: TextStyle(
                                color: CupertinoColors.activeGreen,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            themeData =
                                isDark() ? themeDatalight : themeDatadark;
                          });
                        },
                        icon: Icon(
                          isDark()
                              ? CupertinoIcons.sun_max_fill
                              : CupertinoIcons.moon_stars_fill,
                          color: themeData.iconTheme.color!.withOpacity(.7),
                        ),
                      )
                    ],
                    title: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: 'EGLISE ',
                          style: TextStyle(
                              color: textColor(), fontFamily: "Montserrat"
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
                            ),
                          ]),
                    ),
                  )
                : AppBar(
                    backgroundColor: Colors.black.withOpacity(.07),
                    elevation: 0,
                    // shadowColor: Colors.transparent,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            (current_question + 1).toString() +
                                " / " +
                                list_questions.length.toString(),
                            style: TextStyle(
                                shadows: [
                                  Shadow(
                                      color: Colors.black54,
                                      blurRadius: 2,
                                      offset: Offset(1, 1))
                                ],
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                    // leading: IconButton(
                    //     onPressed: () {
                    //       Navigator.
                    //     },
                    //     icon: Icon(
                    //       CupertinoIcons.chevron_left_circle_fill,
                    //       color: CupertinoColors.white,
                    //     )),
                    centerTitle: true,

                    title: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          text: 'EGLISE ',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Montserrat",
                              shadows: [
                                Shadow(
                                    color: Colors.black54,
                                    blurRadius: 2,
                                    offset: Offset(1, 1))
                              ]),
                          children: [
                            TextSpan(
                              text: 'DE ',
                              style: TextStyle(
                                color: Colors.white,
                                // color: Colors.black,
                                fontWeight: FontWeight.w600,
                                // fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: 'VILLE',
                              style: TextStyle(
                                color: Colors.white,
                                // color: Colors.black,
                                fontWeight: FontWeight.w600,
                                // fontSize: 14,
                              ),
                            )
                          ]),
                    ),
                  ),
            body: GestureDetector(
              onTapUp: (details) {
                if (details.localPosition.dx <
                    MediaQuery.of(context).size.width / 2) {
                  // Clic sur la moitié gauche de l'écran

                  ccontroller.previousPage();
                } else {
                  // Clic sur la moitié droite de l'écran
                  ccontroller.nextPage();
                }
              },
              child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: true
                      ? Column(
                          children: [
                            Flexible(
                              child: CarouselSlider(
                                  carouselController: ccontroller,
                                  items: [
                                    for (var i = 0;
                                        i < list_questions.length;
                                        i++)
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        width: double.infinity,
                                        height: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 25),
                                        decoration: BoxDecoration(
                                            color: isDark()
                                                ? Colors.grey[900]
                                                : Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  offset: Offset(4, 4),
                                                  color: textColor()
                                                      .withOpacity(.1),
                                                  blurRadius: 5)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                                width: 1,
                                                color:
                                                    textColor().withOpacity(.1))
                                            // gradient: LinearGradient(
                                            //     begin: Alignment.topLeft,
                                            //     end: Alignment.bottomRight,
                                            //     colors: get_gradient_color(i))
                                            ),
                                        child: Column(
                                          children: [
                                            Flexible(
                                              child: Center(
                                                child: Text(
                                                  list_questions[i]["question"]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: themeData
                                                      .textTheme.displayLarge!
                                                      .copyWith(fontSize: 23),
                                                ),
                                              ),
                                            ),
                                            true
                                                ? Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    children: [
                                                      for (var rep
                                                          in list_questions[i]
                                                              ["reponses"])
                                                        InkWell(
                                                          onTap: () {
                                                            repondre(i, rep);
                                                          },
                                                          child: Container(
                                                            // width: double.infinity,
                                                            // alignment: Alignment.center,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        5),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        10),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: rep ==
                                                                      list_questions[i]
                                                                              [
                                                                              "reponse"]
                                                                          .toString()
                                                                  ? CupertinoColors
                                                                      .activeOrange
                                                                  : isDark()
                                                                      ? Colors
                                                                          .white
                                                                      : Colors.grey[
                                                                          700],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                            child: Text(
                                                              rep,
                                                              style: TextStyle(
                                                                  color: rep ==
                                                                          list_questions[i]["reponse"]
                                                                              .toString()
                                                                      ? Colors
                                                                          .white
                                                                      : isDark()
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  )
                                                : GridView.count(
                                                    crossAxisCount: 2,
                                                    shrinkWrap: true,
                                                    childAspectRatio:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                120) /
                                                            1,
                                                    mainAxisSpacing: 15,
                                                    crossAxisSpacing: 15,
                                                    children: [
                                                      for (var rep
                                                          in list_questions[i]
                                                              ["reponses"])
                                                        InkWell(
                                                          onTap: () {
                                                            repondre(i, rep);
                                                          },
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            alignment: Alignment
                                                                .center,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    bottom: 5,
                                                                    right: 5),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        10),
                                                            decoration: BoxDecoration(
                                                                color: rep ==
                                                                        list_questions[i]["reponse"]
                                                                            .toString()
                                                                    ? CupertinoColors.activeGreen
                                                                    : Colors.white,
                                                                borderRadius: BorderRadius.circular(4),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black38,
                                                                      blurRadius:
                                                                          2,
                                                                      offset:
                                                                          Offset(
                                                                              2,
                                                                              2))
                                                                ]),
                                                            child: Text(
                                                              rep,
                                                              style: TextStyle(
                                                                  color: rep ==
                                                                          list_questions[i]["reponse"]
                                                                              .toString()
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  )
                                          ],
                                        ),
                                      )
                                  ],
                                  options: CarouselOptions(
                                    height: double.infinity,

                                    // aspectRatio: 16 / 9,
                                    onPageChanged: (int page_pos,
                                        CarouselPageChangedReason reason) {
                                      setState(() {
                                        current_question = page_pos;
                                      });
                                      if (scontroller.hasClients) {
                                        scontroller.animateTo(
                                          current_question.toDouble() * 15,
                                          curve: Curves.easeOut,
                                          duration:
                                              const Duration(milliseconds: 300),
                                        );
                                      }
                                    },
                                    viewportFraction: .85,
                                    initialPage: 0,
                                    enableInfiniteScroll: false,
                                    autoPlay: false,
                                    autoPlayInterval: Duration(seconds: 3),
                                    autoPlayAnimationDuration:
                                        Duration(milliseconds: 800),
                                    autoPlayCurve: Curves.fastOutSlowIn,
                                    enlargeCenterPage: true,
                                    scrollDirection: Axis.horizontal,
                                  )),
                            ),
                            Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: scontroller,
                                child: DotsIndicator(
                                  dotsCount: list_questions.length,
                                  position: current_question.toDouble(),
                                  decorator: DotsDecorator(
                                    size: const Size.square(7.0),
                                    activeColor: CupertinoColors.activeOrange,
                                    color: Colors.grey,
                                    activeSize: const Size(20, 10),
                                    activeShape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: MaterialButton(
                                    color: Colors.grey[900],
                                    elevation: 0,
                                    textColor: Colors.white,
                                    onPressed: soumettre_reponses,
                                    minWidth: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 7),
                                    child: Text(
                                      "Soumettre mes réponses",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ))
                          ],
                        )
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: CarouselSlider(
                                  carouselController: ccontroller,
                                  items: [
                                    for (var i = 0;
                                        i < list_questions.length;
                                        i++)
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 15),
                                        width: double.infinity,
                                        height: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            vertical:
                                                AppBar().preferredSize.height,
                                            horizontal: 25),
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: get_gradient_color(i))),
                                        child: Column(
                                          children: [
                                            Flexible(
                                              child: Center(
                                                child: Text(
                                                  list_questions[i]["question"]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 25),
                                                ),
                                              ),
                                            ),
                                            true
                                                ? Wrap(
                                                    children: [
                                                      for (var rep
                                                          in list_questions[i]
                                                              ["reponses"])
                                                        InkWell(
                                                          onTap: () {
                                                            repondre(i, rep);
                                                          },
                                                          child: Container(
                                                            // width: double.infinity,
                                                            // alignment: Alignment.center,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        5),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        10),
                                                            decoration: BoxDecoration(
                                                                color: rep ==
                                                                        list_questions[i]["reponse"]
                                                                            .toString()
                                                                    ? CupertinoColors.activeGreen
                                                                    : Colors.white,
                                                                borderRadius: BorderRadius.circular(4),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black38,
                                                                      blurRadius:
                                                                          2,
                                                                      offset:
                                                                          Offset(
                                                                              2,
                                                                              2))
                                                                ]),
                                                            child: Text(
                                                              rep,
                                                              style: TextStyle(
                                                                  color: rep ==
                                                                          list_questions[i]["reponse"]
                                                                              .toString()
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  )
                                                : GridView.count(
                                                    crossAxisCount: 2,
                                                    shrinkWrap: true,
                                                    childAspectRatio:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                120) /
                                                            1,
                                                    mainAxisSpacing: 15,
                                                    crossAxisSpacing: 15,
                                                    children: [
                                                      for (var rep
                                                          in list_questions[i]
                                                              ["reponses"])
                                                        InkWell(
                                                          onTap: () {
                                                            repondre(i, rep);
                                                          },
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            alignment: Alignment
                                                                .center,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    bottom: 5,
                                                                    right: 5),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        10),
                                                            decoration: BoxDecoration(
                                                                color: rep ==
                                                                        list_questions[i]["reponse"]
                                                                            .toString()
                                                                    ? CupertinoColors.activeGreen
                                                                    : Colors.white,
                                                                borderRadius: BorderRadius.circular(4),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black38,
                                                                      blurRadius:
                                                                          2,
                                                                      offset:
                                                                          Offset(
                                                                              2,
                                                                              2))
                                                                ]),
                                                            child: Text(
                                                              rep,
                                                              style: TextStyle(
                                                                  color: rep ==
                                                                          list_questions[i]["reponse"]
                                                                              .toString()
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  )
                                          ],
                                        ),
                                      )
                                  ],
                                  options: CarouselOptions(
                                    height: double.infinity,

                                    // aspectRatio: 16 / 9,
                                    onPageChanged: (int page_pos,
                                        CarouselPageChangedReason reason) {
                                      setState(() {
                                        current_question = page_pos;
                                      });
                                      if (scontroller.hasClients) {
                                        scontroller.animateTo(
                                          current_question.toDouble() * 15,
                                          curve: Curves.easeOut,
                                          duration:
                                              const Duration(milliseconds: 300),
                                        );
                                      }
                                    },
                                    viewportFraction: 1,
                                    initialPage: 0,
                                    enableInfiniteScroll: false,
                                    autoPlay: false,
                                    autoPlayInterval: Duration(seconds: 3),
                                    autoPlayAnimationDuration:
                                        Duration(milliseconds: 800),
                                    autoPlayCurve: Curves.fastOutSlowIn,
                                    enlargeCenterPage: true,
                                    scrollDirection: Axis.horizontal,
                                  )),
                            ),
                            Positioned(
                                bottom: 10,
                                right: 20,
                                left: 20,
                                child: peut_soumettre()
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: MaterialButton(
                                          color: CupertinoColors.activeGreen,
                                          elevation: 0,
                                          textColor: Colors.white,
                                          onPressed: soumettre_reponses,
                                          minWidth: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 7),
                                          child: Text(
                                            "Soumettre mes réponses",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          controller: scontroller,
                                          child: DotsIndicator(
                                            dotsCount: list_questions.length,
                                            position:
                                                current_question.toDouble(),
                                            decorator: DotsDecorator(
                                              size: const Size.square(7.0),
                                              activeColor: Colors.white,
                                              color: Colors.white38,
                                              activeSize: const Size(20, 10),
                                              activeShape:
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0)),
                                            ),
                                          ),
                                        ),
                                      ))
                          ],
                        )),
            )),
      ),
    );
  }

  List<Color> get_gradient_color(int index) {
    List<List<Color>> color_list = [
      // [
      //   Colors.purple,
      //   Colors.indigo[800]!,
      // ],
      [
        Color(0xffD65DB1),
        Color(0xffFF6F91),
        Color(0xffFF9671),
      ],

      [
        Color(0xff00f2fe),
        Color(0xff4facfe),
      ],
      [
        Colors.pink,
        Colors.purple,
      ],
      [
        Color(0xff2af598),
        Color(0xff009efd),
      ],
    ];

    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    return color_list[index];
  }
}
