import 'dart:convert';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eglise_de_ville/api_operation.dart';
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
import '../contante_var2.dart';
import 'quiz/homeQuiz.dart';

import 'package:flutter_timer_countdown/flutter_timer_countdown.dart' as tc;
// import 'package:html_editor_enhanced/html_editor.dart';

class LectureCours extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  LectureCours(this.map_data);

  @override
  State<LectureCours> createState() => _LectureCoursState(this.map_data);
}

class _LectureCoursState extends State<LectureCours> {
  bool isload = false;
  Map<String, dynamic> map_data;
  _LectureCoursState(this.map_data) {
    if (map_data["ch_Contenu"] != null) {
      _controller = fq.QuillController(
        document: fq.Document.fromJson(jsonDecode(map_data["ch_Contenu"])),
        selection: TextSelection.collapsed(offset: 0),
      );
      // _controller.ignoreFocusOnTextChange = true;
    }
  }
  fq.QuillController _controller = fq.QuillController.basic();

  List<Map<String, dynamic>> list_verset = [];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  void charger_verset() async {
    setState(() {
      isload = true;
    });

    setState(() {
      isload = false;
    });
  }

  void charger_quiz() async {
    showloading(context);
    var str = (""" SELECT *, 
(SELECT ((900)-round(time_to_sec(timediff(current_timestamp,Date )))) from composer_quiz 
WHERE user_id='${connected_user["id"].toString()}'
 AND quiz_id=Q.id AND 
round(time_to_sec(timediff(current_timestamp,
Date ))/60) < 15 
LIMIT 1) deja, 

(SELECT Avis from composer_quiz WHERE user_id='${connected_user["id"].toString()}' AND quiz_id=Q.id AND Avis="SUCCESS" LIMIT 1 ) jamais
 from Quiz Q where id_chapitre='${map_data["ch_id"].toString()}'
""");

    var t = await select_data(str);

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      exitloading(context);

      if (t.first['jamais'].toString() == "SUCCESS") {
        showMessageJolie("Félicitation", "Vous avez déjà réussi ce test là",
            CupertinoColors.activeGreen, context);
      } else if (t.first["deja"] == null) {
        await insert_data({
          "user_id": connected_user["id"],
          "quiz_id": t.first["id"],
          "Details": "",
          "Note": "0",
          "Avis": "ECHEC",
        }, "composer_quiz");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QuizHome({"quiz": t.first})));
      } else {
        exitloading(context);
        showModal(
            filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
            context: context,
            builder: (context) => Theme(
                  data: themeData,
                  child: AlertDialog(
                      // actions: [
                      //   IconButton(
                      //       onPressed: () {
                      //         Navigator.pop(context);
                      //       },
                      //       icon: Icon(
                      //         CupertinoIcons.xmark_circle_fill,
                      //         color: Colors.green,
                      //       ))
                      // ],
                      content: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Patientez ...",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontFamily: 'Roboto'),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        tc.TimerCountdown(
                          onEnd: (() {
                            Navigator.pop(context);
                            charger_quiz();
                          }),
                          format: tc.CountDownTimerFormat.minutesSeconds,
                          secondsDescription: "Secondes",
                          timeTextStyle: TextStyle(
                              fontFamily: "Circular",
                              fontWeight: FontWeight.bold,
                              fontSize: 35),
                          endTime: DateTime.now().add(Duration(
                              seconds:
                                  int.parse(t.first["deja"].toString()) + 1)),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        MaterialButton(
                          minWidth: double.infinity,
                          elevation: 0,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          color: Colors.orange,
                          textColor: Colors.white,
                          child: Text(
                            "Relire le chapitre",
                            style: TextStyle(fontFamily: "Roboto"),
                          ),
                        ),
                      ],
                    ),
                  )
                      //  TimerFrame(
                      //         description: 'Customized Timer Countdown',
                      //         timer: TimerBasic(
                      //           format: CountDownTimerFormat.daysHoursMinutesSeconds,
                      //         ),
                      //       ),,
                      ),
                ));
        // showMessageJolie(
        //     "Désolé",
        //     "Vous avez déjà passé le test aujourd'hui. Vous devez attendre encore " +
        //         t.first["deja"].toString() +
        //         " minute(s)",
        //     CupertinoColors.activeGreen,
        //     context);

        //vous avez déjà passé le test aujourd'hui, vous devez relire le chapitre et revenir composer demain
      }
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      exitloading(context);

      showMessage("Erreur", t[0]["error"].toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: themeData.scaffoldBackgroundColor,
          // extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: themeData.scaffoldBackgroundColor,
            elevation: 1,
            shadowColor: isDark() ? Colors.grey[100] : null,
            leading: IconButton(
                onPressed: () {
                  exitloading(context);
                },
                icon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: CupertinoColors.systemRed,
                )),
            centerTitle: true,
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
                  color: themeData.iconTheme.color!.withOpacity(.7),
                ),
              )
            ],
            title: Text(
              map_data["Titre"].toString(),
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: CupertinoColors.activeGreen),
            ),
          ),
          body: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 0),
              child: Column(
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                    text: "Chapitre " +
                                        map_data["ch_num_chapitre"].toString() +
                                        " : ",
                                    style: TextStyle(
                                        color: themeData
                                            .textTheme.bodyText1!.color,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "SourceSansPro"),
                                    children: [
                                      TextSpan(
                                        text: map_data["ch_Titre"].toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: themeData
                                                .textTheme.bodyText1!.color),
                                      ),
                                    ]),
                              ),
                            ),

                            Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 20),
                                child: fq.QuillEditor(
                                  controller: _controller,
                                  scrollController: ScrollController(),
                                  customStyles: fq.DefaultStyles(),
                                  scrollable: true,
                                  enableInteractiveSelection: false,
                                  focusNode: FocusNode(),
                                  autoFocus: true,
                                  readOnly: true,
                                  expands: false,
                                  padding: EdgeInsets.zero,
                                  showCursor: false,
                                  // true for view only mode
                                )),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: true
                                  ? InkWell(
                                      onTap: () {
                                        // inserer_local('chapitre_lu', {
                                        //   "id_chapitre": map_data["ch_id"],
                                        //   "Date": DateTime.now().toString(),
                                        // });
                                        //showModalBottomSheet(context: context, builder: builder)
                                        // showCupertinoModalPopup
                                        showModalBottomSheet(
                                            // filter: ImageFilter.blur(
                                            //     sigmaX: 15, sigmaY: 15),
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => true
                                                ? Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 20,
                                                            horizontal: 10),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10)),
                                                        color: isDark()
                                                            ? Colors.grey[900]
                                                            : Colors.white),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            "Félicitations",
                                                            style: themeData
                                                                .textTheme
                                                                .headline4,
                                                          ),
                                                          LottieBuilder.asset(
                                                            map_data["ch_Avis"] ==
                                                                    "SUCCESS"
                                                                ? "assets/lotties/lf20_kfl4ksd9.json"
                                                                : "assets/lotties/lf20_6aYlBl.json",
                                                            repeat: true,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .75,
                                                          ),
                                                          map_data["ch_quiz"] ==
                                                                      null ||
                                                                  map_data[
                                                                          "ch_Avis"] ==
                                                                      "SUCCESS"
                                                              ? SizedBox(
                                                                  height: 0)
                                                              : ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  child:
                                                                      MaterialButton(
                                                                    color: Colors
                                                                        .orange,
                                                                    elevation:
                                                                        0,
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                    onPressed:
                                                                        charger_quiz,
                                                                    minWidth: double
                                                                        .infinity,
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            15,
                                                                        horizontal:
                                                                            7),
                                                                    child: Text(
                                                                      "Passer le test de compréhension",
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                          map_data["ch_quiz"] ==
                                                                      null ||
                                                                  map_data[
                                                                          "ch_Avis"] ==
                                                                      "SUCCESS"
                                                              ? SizedBox(
                                                                  height: 0)
                                                              : Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    "Vous devez réussir ce test afin de passer au chapitre suivant",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        color: textColor().withOpacity(
                                                                            .5),
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : AlertDialog(
                                                    backgroundColor: isDark()
                                                        ? Colors.white
                                                            .withOpacity(.4)
                                                        : Colors.white,
                                                    title: SizedBox(
                                                      width: double.infinity,
                                                      child: Text(
                                                          "Félicitation",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color:
                                                                  textColor(),
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  "Circular",
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    ),
                                                    actions: [
                                                      IconButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          icon: Icon(
                                                              CupertinoIcons
                                                                  .xmark_circle_fill,
                                                              color: CupertinoColors
                                                                  .activeGreen)),
                                                    ],
                                                    content: Container(
                                                      child: IntrinsicHeight(
                                                        child: Column(
                                                          children: [
                                                            LottieBuilder.asset(
                                                              map_data["ch_Avis"] ==
                                                                      "SUCCESS"
                                                                  ? "assets/lotties/lf20_kfl4ksd9.json"
                                                                  : "assets/lotties/lf20_6aYlBl.json",
                                                              repeat: false,
                                                            ),
                                                            map_data["ch_quiz"] ==
                                                                        null ||
                                                                    map_data[
                                                                            "ch_Avis"] ==
                                                                        "SUCCESS"
                                                                ? SizedBox(
                                                                    height: 0)
                                                                : ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                    child:
                                                                        MaterialButton(
                                                                      color: Colors
                                                                          .orange,
                                                                      elevation:
                                                                          0,
                                                                      textColor:
                                                                          Colors
                                                                              .white,
                                                                      onPressed:
                                                                          charger_quiz,
                                                                      minWidth:
                                                                          double
                                                                              .infinity,
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              15,
                                                                          horizontal:
                                                                              7),
                                                                      child:
                                                                          Text(
                                                                        "Passer le test de compréhension",
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                            map_data["ch_quiz"] ==
                                                                        null ||
                                                                    map_data[
                                                                            "ch_Avis"] ==
                                                                        "SUCCESS"
                                                                ? SizedBox(
                                                                    height: 0)
                                                                : Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      "Attention, vous ne pouvez composer une seule fois par jour",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontStyle: FontStyle
                                                                              .italic,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ));
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.activeGreen,
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: Text(
                                          "J'ai terminé ce chapitre !!",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: CupertinoColors.activeGreen,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black45,
                                                blurRadius: 5)
                                          ]),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      QuizHome({})));
                                        },
                                        child: Icon(
                                          CupertinoIcons.checkmark_alt,
                                          color: CupertinoColors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            // SizedBox(
                            //   height: 15,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ))),
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
