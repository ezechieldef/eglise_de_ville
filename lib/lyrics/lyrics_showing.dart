import 'dart:convert';
import 'dart:ui';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:html_editor/html_editor.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../contantes.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

class ReadLyrics extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  ReadLyrics(Map<String, dynamic> k) {
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
  State<ReadLyrics> createState() => _ReadLyricsState(this.map_data);
}

class _ReadLyricsState extends State<ReadLyrics> {
  bool isload = false;
  Map<String, dynamic> map_data;
  fq.QuillController _controller = fq.QuillController.basic();

  _ReadLyricsState(this.map_data) {
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
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          // backgroundColor: Color(0xfffafafa),
          appBar: AppBar(
            centerTitle: true,
            elevation: 1,

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
            // actions: [
            //   IconButton(
            //       onPressed: () {
            //         // chargement();
            //       },
            //       icon: Icon(
            //         CupertinoIcons.refresh_circled_solid,
            //         color: Colors.grey,
            //       ))
            // ],
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
          body: Stack(
            children: [
              Positioned(
                  bottom: 0,
                  right: 0,
                  // left: 0,
                  child: Hero(
                    tag: "grand",
                    child: Opacity(
                      opacity: .5,
                      child: Container(
                        // width: 150,
                        // height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.width * (2 / 3),
                        child: ShaderMask(
                          blendMode: BlendMode.srcATop,
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Color(0xff009BFF),
                                Color(0xff00BCFF),
                                Color(0xff00D6E9),
                                Color(0xff00E9B9),
                                Color(0xff97F58A),
                                Color(0xffF9F871),
                              ],
                            ).createShader(bounds);
                          },
                          child: LottieBuilder.asset(
                              "assets/lotties/lf30_1uthde7u.json"),
                        ),
                      ),
                    ),
                  )),
              Positioned.fill(
                child: Container(
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
                                child: InkWell(
                                  onTap: (map_data["Audio"]
                                                  .toString()
                                                  .toLowerCase() ==
                                              "null" ||
                                          map_data["Audio"].toString().isEmpty)
                                      ? null
                                      : () {
                                          launchUrl(
                                              Uri.parse(
                                                  map_data["Audio"].toString()),
                                              mode: LaunchMode
                                                  .externalNonBrowserApplication);
                                        },
                                  child: Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      // padding: EdgeInsets.symmetric(
                                      //     horizontal: 7, vertical: 10),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Colors.red,
                                                Colors.red[800]!
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight),
                                          // gradient: LinearGradient(
                                          //     begin: Alignment.topLeft,
                                          //     end: Alignment.bottomRight,
                                          //     colors: [
                                          //       // Color(0xffD65DB1),
                                          //       // Color(0xffFF6F91),
                                          //       // Color(0xffFF9671),
                                          //       // Color(0xffFFC75F),

                                          //     ]),

                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Material(
                                          type: MaterialType.transparency,
                                          color: Colors.transparent,
                                          child: ListTile(
                                            // textColor: Colors.white,
                                            leading: Icon(
                                              CupertinoIcons.music_note,
                                              color: Colors.white,
                                            ),

                                            title: Text(
                                              map_data["Titre"].toString(),
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            subtitle: (map_data["Audio"]
                                                            .toString()
                                                            .toLowerCase() ==
                                                        "null" ||
                                                    map_data["Audio"]
                                                        .toString()
                                                        .isEmpty)
                                                ? SizedBox(
                                                    width: double.infinity,
                                                    child: Text(
                                                      "Audio non disponible",
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ))
                                                : Text(
                                                    "Cliquez pour suivre l'audio",
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                          ))),
                                ),
                              ),
                              Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 10),
                                  decoration: BoxDecoration(
                                      // color: Colors.white,
                                      ),
                                  child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
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
            ],
          )),
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
