import 'dart:convert';
import 'dart:ui';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:html_editor/html_editor.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

import '../../contantes.dart';
import '../contante_var2.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

class ReadArticleEnseignement extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  ReadArticleEnseignement(Map<String, dynamic> k) {
    if (k.isEmpty) {
      map_data = {
        "Titre": "-",
        "Verset": "-",
        "Contenu": null,
      };
    } else {
      map_data = k;
    }
  }

  @override
  State<ReadArticleEnseignement> createState() =>
      _ReadArticleEnseignementState(this.map_data);
}

class _ReadArticleEnseignementState extends State<ReadArticleEnseignement>
    with TickerProviderStateMixin {
  bool isload = false;
  Map<String, dynamic> map_data;
  fq.QuillController _controller = fq.QuillController.basic();
  late final AnimationController _lottie_controller;

  _ReadArticleEnseignementState(this.map_data) {
    if (map_data["Contenu"] != null) {
      _controller = fq.QuillController(
          document: fq.Document.fromJson(jsonDecode(map_data["Contenu"])),
          selection: TextSelection.collapsed(offset: 0));
      // _controller.ignoreFocusOnTextChange = true;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lottie_controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _lottie_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.5,
          // backgroundColor: Colors.white,
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
                exitloading(context);
              },
              icon: Icon(
                CupertinoIcons.xmark_circle_fill,
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
            // color: Colors.yellow,
            child: isload
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Column(children: [
                      Hero(
                        tag: map_data["id"].toString() + "htag",
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
                            margin: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 7, vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xffff9a44),
                                      Color(0xfffc6076),
                                    ]),
                                // image: DecorationImage(
                                //     fit: BoxFit.cover,
                                //     opacity: 0.35,
                                //     image: AssetImage(
                                //       "assets/image/bg_sky.jpg",
                                //     )),

                                borderRadius: BorderRadius.circular(8)),
                            child: Material(
                              type: MaterialType.transparency,
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      map_data["Titre"].toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 15,
                                          height: 1.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        map_data["Verset"].toString(),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.white),
                                      )),
                                ],
                              ),
                            )),
                      ),
                      Container(
                          width: double.infinity,
                          padding:
                              EdgeInsets.symmetric(horizontal: 7, vertical: 10),
                          decoration: BoxDecoration(
                              // color: Colors.white,
                              ),
                          child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: fq.QuillEditor(
                                controller: _controller,

                                scrollController: ScrollController(),
                                scrollable: true,
                                focusNode: FocusNode(),
                                autoFocus: true,
                                readOnly: true,
                                expands: false,
                                padding: EdgeInsets.zero,
                                showCursor: false,
                                // true for view only mode
                              ))),
                    ]),
                  )),
      ),
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
