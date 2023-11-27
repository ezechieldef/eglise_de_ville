import 'dart:convert';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/lyrics/lyrics_showing.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:lottie/lottie.dart';

class LyricsHome extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  LyricsHome(this.zoomDrawerController);

  @override
  State<LyricsHome> createState() => _LyricsHomeState();
}

class _LyricsHomeState extends State<LyricsHome> with TickerProviderStateMixin {
  List<Map<String, dynamic>> list_lyric = [];
  bool isload = false;
  Future<void> chargement({String search = ""}) async {
    setState(() {
      isload = true;
      list_lyric = [];
    });
    var t = await select_data(
        'SELECT * from Lyrics WHERE Titre LIKE "%$search%" OR contenu LIKE "%$search%" ORDER BY Date DESC ');
    print(t);
    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_lyric = t;
      });
      inserer_local_list("Lyrics", t);
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage("Avertissement", internet_off_str, context);
      try {
        var t2 = await select_local_sqlite(
            'SELECT * from Lyrics WHERE Titre LIKE "%$search%" OR contenu LIKE "%$search%"  ',
            []);
        setState(() {
          list_lyric = t2;
        });
      } catch (e) {}
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
          // backgroundColor: Colors.grey[200],
          backgroundColor: isDark() ? Colors.black : Color(0xfffafafa),
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: isDark()
                ? Colors.black
                : Color(
                    0xfffafafa), //Colors.black.withOpacity(0.3), //Colors.white,

            leading: IconButton(
                onPressed: () {
                  widget.zoomDrawerController.toggle!();
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.red,
                )),
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
            title: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: 'EGLISE ',
                  style:
                      TextStyle(color: textColor(), fontFamily: "Montserrat"),
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
            child: isload
                ? Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "Lyrics".toUpperCase(),
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
                              color: textColor(),
                              fontFamily: "SourceSansPro",
                              fontSize: 14),
                          // backgroundColor: Colors.white,
                          placeholder: "Rechercher ...",
                          onSubmitted: (v) {
                            chargement(search: v);
                          },
                          prefixInsets: EdgeInsets.symmetric(horizontal: 15),
                          suffixInsets: EdgeInsets.symmetric(horizontal: 15),
                          // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          placeholderStyle: TextStyle(
                            fontFamily: "SourceSansPro",
                            color: textColor().withOpacity(.7),
                          ),
                        ),
                      ),
                      Flexible(
                          child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: list_lyric.length == 0
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Text("Aucune données disponible "),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Flexible(
                                      child: LottieBuilder.asset(
                                          "assets/lotties/lf20_n2m0isqh.json")),
                                ],
                              )
                            : ListView.builder(
                                // separatorBuilder: (context, index) {
                                //   return Divider(
                                //     indent: 10,
                                //     endIndent: 10,
                                //     height: 1,
                                //     color: Colors.grey[200],
                                //   );
                                // },
                                physics: AlwaysScrollableScrollPhysics(),
                                itemBuilder: ((context, index) {
                                  var myJSON = jsonDecode(
                                      list_lyric[index]["Contenu"].toString());
                                  fq.QuillController _control_doc =
                                      fq.QuillController(
                                          document:
                                              fq.Document.fromJson(myJSON),
                                          selection: TextSelection.collapsed(
                                              offset: 0));

                                  return SlideTransition(
                                    position: _animation!,
                                    child: Hero(
                                      tag: list_lyric[index]["id"].toString() +
                                          "htag",
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 5),
                                          decoration: BoxDecoration(
                                              color: isDark()
                                                  ? Colors.white
                                                      .withOpacity(0.4)
                                                  : Colors.white,
                                              // image: DecorationImage(
                                              //     fit: BoxFit.cover,
                                              //     opacity: 0.3,
                                              //     image: AssetImage(
                                              //       "assets/image/bg_sky.jpg",
                                              //     )),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                isDark()
                                                    ? BoxShadow()
                                                    : BoxShadow(
                                                        color:
                                                            Colors.grey[300]!,
                                                        blurRadius: 4,
                                                        offset: Offset(3, 3))
                                              ]),
                                          child: ListTile(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReadLyrics(list_lyric[
                                                              index]))).then(
                                                  (value) {
                                                // chargement();
                                              });
                                            },
                                            trailing: (list_lyric[index]
                                                                ["Audio"]
                                                            .toString()
                                                            .toLowerCase() ==
                                                        "null" ||
                                                    list_lyric[index]["Audio"]
                                                        .toString()
                                                        .isEmpty)
                                                ? null
                                                : Icon(FontAwesomeIcons
                                                    .headphonesSimple),
                                            title: Text(list_lyric[index]
                                                    ["Titre"]
                                                .toString()),
                                            subtitle: Text(
                                              _control_doc.document
                                                  .toPlainText()
                                                  .toString()
                                                  .replaceAll("\n", " "),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            leading: ShaderMask(
                                              blendMode: BlendMode.srcATop,
                                              shaderCallback: (bounds) {
                                                return LinearGradient(
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                  colors: [
                                                    Colors.pinkAccent,
                                                    Colors.pink[700]!,
                                                  ],
                                                ).createShader(bounds);
                                              },
                                              child: Icon(
                                                CupertinoIcons.music_note,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                itemCount: list_lyric.length,
                              ),
                      ))
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
