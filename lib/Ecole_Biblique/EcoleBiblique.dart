import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:eglise_de_ville/Ecole_Biblique/api_operation_laravel.dart';
import 'package:eglise_de_ville/Ecole_Biblique/audioPlaying.dart';
import 'package:eglise_de_ville/Ecole_Biblique/gpt.dart';
import 'package:eglise_de_ville/Ecole_Biblique/recordingpage.dart';
import 'package:eglise_de_ville/api_operation_laravel.dart';

import 'package:eglise_de_ville/const_notification.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/serveur_custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:audio_waveforms_fix/audio_waveforms.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

// import '../api_operation_laravel.dart';
import '../profile_view.dart';
import 'package:http/http.dart' as http;

class EcoleBiblique extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  EcoleBiblique(this.zoomDrawerController);

  @override
  State<EcoleBiblique> createState() => _EcoleBibliqueState();
}

class _EcoleBibliqueState extends State<EcoleBiblique>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> list_cours = [];
  AnimationController? _controller;
  Animation<Offset>? _animation;
  bool isload = false;
  bool isParter = false;
  bool isAdmin = false;
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
    firstLoading().then((value) {
      chargement();
    });
    if (mounted)
      setState(() {
        isload = true;
        list_cours = [];
      });

    // This callback is called every time the brightness changes.
  }

  Future<void> firstLoading() async {
    if (connected_user.isNotEmpty) {
      if (mounted)
        setState(() {
          isload = true;
        });

      var t = await select_data(
        'SELECT * from admins where email="${connected_user["email"].toString()}" ',
      );
      print(t);

      if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
        var roles = t.first;
        if (jsonDecode(roles["roles"].toString()).contains("PARTNER")) {
          setState(() {
            isParter = true;
          });
        }
        if (jsonDecode(roles["roles"].toString()).contains("ADMIN")) {
          setState(() {
            isAdmin = true;
          });
        }
        print("roles $roles");
      }
      if (mounted)
        setState(() {
          isload = false;
        });
    }
  }

  Future<void> chargement({String search = ""}) async {
    if (mounted)
      setState(() {
        isload = true;
        list_cours = [];
      });

    var resp = await http.get(
      Uri.parse(serveur_ecole_biblique + "?search=$search"),
    );

    List<Map<String, dynamic>> l = [];
    jsonDecode(resp.body).forEach((element) {
      Map<String, dynamic> m = {};
      element.forEach((key, value) {
        m[key] = value;
      });
      l.add(m);
    });
    if (mounted)
      setState(() {
        list_cours = l;
        isload = false;
      });

    _controller!.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _controller!.dispose();
    _animation = null;
    super.dispose();
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
              // extendBodyBehindAppBar: true,
              // extendBody: true,
              floatingActionButton:
                  (isParter || isAdmin) && connected_user.isNotEmpty
                      ? FloatingActionButton(
                          onPressed: () {
                            //pushr2(context, Enregistrement());
                            Navigator.push(
                                context, routeTransition(Enregistrement({})));
                          },
                          backgroundColor: Colors.red,
                          child: Icon(Icons.add),
                        )
                      : null,
              appBar: AppBar(
                centerTitle: true,
                elevation: 0.5,
                // backgroundColor: Color(
                //     0xffFAFAFA), //Colors.black.withOpacity(0.3), //Colors.white,
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
                  ),
                  connected_user.isNotEmpty
                      ? SizedBox()
                      : IconButton(
                          onPressed: () async {
                            await checkLogin(context);
                            setState(() {
                              connected_user = connected_user;
                            });
                          },
                          icon: Icon(Icons.mic))
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
                          color: textColor(), fontFamily: "Montserrat"),
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 0),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        child: CupertinoSearchTextField(
                          onSuffixTap: () {
                            chargement();
                          },

                          style: TextStyle(
                              fontFamily: "Material", color: textColor()),
                          backgroundColor:
                              themeData.brightness == Brightness.light
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
                      // ProfileView(),
                      SizedBox(
                        height: 10,
                      ),
                      // connected_user.isEmpty
                      //     ? MaterialButton(
                      //         onPressed: () async {
                      //           await checkLogin(context);
                      //           setState(() {
                      //             connected_user = connected_user;
                      //           });
                      //         },
                      //         child: Text("S'authentifier"),
                      //         color: CupertinoColors.activeGreen,
                      //         minWidth: double.infinity,
                      //         textColor: Colors.white,
                      //       )
                      //     : SizedBox(),
                      Flexible(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: isload
                              ? Center(
                                  child: CupertinoActivityIndicator(),
                                )
                              : list_cours.isEmpty
                                  ? Center(
                                      child: Text("Aucune données disponible"))
                                  : ListView.builder(
                                      physics: AlwaysScrollableScrollPhysics(),
                                      // shrinkWrap: true,
                                      itemCount: list_cours.length,
                                      itemBuilder: ((context, index) {
                                        return GestureDetector(
                                          onLongPress: isAdmin
                                              ? () {
                                                  showModalBottomSheet(
                                                      context: context,
                                                      backgroundColor: Colors
                                                          .transparent,
                                                      elevation: 0,
                                                      enableDrag: true,
                                                      builder: (context) =>
                                                          AlertActionEns(
                                                              list_cours[
                                                                  index])).then(
                                                      (value) {
                                                    if (value != null &&
                                                        value) {
                                                      chargement();
                                                    }
                                                  });
                                                  // showCupertinoModalPopup(
                                                  //     filter: ImageFilter.blur(
                                                  //         sigmaX: 10, sigmaY: 10),
                                                  //     context: context,
                                                  //     builder: );
                                                }
                                              : null,
                                          child: OpenContainer(
                                            openElevation: 0,
                                            openColor: Colors.transparent,
                                            closedColor: Colors.transparent,
                                            middleColor: Colors.transparent,
                                            closedElevation: 0,
                                            transitionDuration:
                                                Duration(milliseconds: 500),
                                            openBuilder: (context, action) =>
                                                AudioPlaying(
                                                    map_data:
                                                        list_cours[index]),
                                            closedBuilder: (context, action) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 7),
                                                child: SlideTransition(
                                                  position: _animation!,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        boxShadow:
                                                            isDark()
                                                                ? []
                                                                : [
                                                                    BoxShadow(
                                                                        color: Colors.grey[
                                                                            200]!,
                                                                        offset: Offset(
                                                                            4,
                                                                            4),
                                                                        blurRadius:
                                                                            10)
                                                                  ],
                                                        color: isDark()
                                                            ? Colors.white
                                                                .withOpacity(.3)
                                                            : Colors.white),
                                                    child: ListTile(
                                                      leading: Icon(
                                                        Icons
                                                            .multitrack_audio_rounded,
                                                        color:
                                                            Colors.amber[600],
                                                        size: 30,
                                                      ),
                                                      title: Text(
                                                        list_cours[index]
                                                                ["Titre"]
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Circular",
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      subtitle: Text(
                                                        list_cours[index]
                                                                ["AuthorName"]
                                                            .toString(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: textColor()
                                                                .withOpacity(
                                                                    .8)),
                                                      ),
                                                      trailing: RotatedBox(
                                                          quarterTurns: 1,
                                                          child:
                                                              IntrinsicHeight(
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  formatDurationStr(
                                                                          list_cours[index]
                                                                              [
                                                                              "Duration"])
                                                                      .toString()
                                                                      .replaceAll(
                                                                          ":",
                                                                          " : "),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: textColor()
                                                                          .withOpacity(
                                                                              .7),
                                                                      fontFamily:
                                                                          "Circular"),
                                                                ),
                                                                SizedBox(
                                                                  width: 40,
                                                                  child:
                                                                      Divider(
                                                                    color: textColor()
                                                                        .withOpacity(
                                                                            .5),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          )),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      })),
                        ),
                      )
                    ],
                  ))),
        ));
  }

  Future<String> c(String url) async {
    FileInfo? info =
        await DefaultCacheManager().getFileFromCache(url, ignoreMemCache: true);
    if (info == null) {
      print("listeninh non $info 1 jamais");

      return "Nouveau".toUpperCase();
    } else {
      print("listeninh $info");
      return "Déjà lu".toUpperCase();
    }
  }

  String formatDurationStr(String duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";

      return "0$n";
    }

    var t = duration.split(":").map((e) => int.parse(e)).toList();
    if (t.length < 2) {
      return duration;
    }

    String hours = twoDigits(t[0]);
    String minutes = twoDigits(t[1]);
    String seconds = twoDigits(t[2]);
    if (t[0] == 0) {
      return "$minutes:$seconds";
    }
    return "$hours:$minutes:$seconds";
  }
}

class AlertActionEns extends StatefulWidget {
  Map<String, dynamic> map_data;
  AlertActionEns(this.map_data);

  @override
  State<AlertActionEns> createState() => AlertActionEnsState();
}

class AlertActionEnsState extends State<AlertActionEns> {
  bool conf = false;
  String rest = '';
  Timer? timer;
  bool isload = false;
  late MyForm formulaire;

  Function()? click_sup = null;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    formulaire = MyForm(
      widget.map_data,
      withIcon: false,
    );

    setState(() {
      click_sup = demarer_timer;
    });
  }

  void demarer_timer() {
    setState(() {
      conf = true;
      rest = "( 5s )";
    });
    timer = Timer.periodic(Duration(seconds: 1), (timerr) {
      setState(() {
        rest = "( " + (5 - timerr.tick).toString() + "s )";
      });

      if (timerr.tick == 6) {
        setState(() {
          rest = "";
          timerr.cancel();
          click_sup = supression;
        });
      }
    });
    setState(() {
      click_sup = null;
    });
  }

  void supression() async {
    setState(() {
      isload = true;
    });
    var r = await exec_mysql_query("DELETE from ecole_biblique WHERE id=" +
        widget.map_data["id"].toString());
    if (r != null && r) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Cours Supprimé ✅")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Une erreur s'est produite ")));
    }
    setState(() {
      isload = false;
    });
    Navigator.pop(context, true);
  }

  void editBtn() async {
    var temp = formulaire.getFormData();
    print("click");
    if (temp == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("Vous devez d'abord remplir le formulaire"),
        backgroundColor: Colors.red,
      ));
      return;
    } else if (temp.containsValue(null) || temp.containsValue("")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Vous devez d'abord remplir le formulaire"),
          backgroundColor: Colors.red,
        ),
      );
    }

    temp.forEach((key, valuer) {
      setState(() {
        widget.map_data.update(key, (value) => valuer);
      });
    });
    setState(() {
      isload = true;
    });

    Map<String, dynamic> conn =
        await insert_data(widget.map_data, "ecole_biblique");
    setState(() {
      isload = false;
    });
    Navigator.pop(context, true);

    if (conn["status"] != "OK") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Nous n'avons pas pu mettre à jour le cours ❌")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cours Mis à jour avec succès ✅")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Container(
          // title: Text(widget.map_data["Titre"].toString()),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
              color: isDark() ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: isload
              ? Container(
                  height: MediaQuery.of(context).size.height * .4,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isDark()
                                    ? []
                                    : [
                                        BoxShadow(
                                            color: Colors.grey[200]!,
                                            offset: Offset(4, 4),
                                            blurRadius: 10)
                                      ],
                                color: isDark()
                                    ? Colors.white.withOpacity(.3)
                                    : Colors.white),
                            child: ListTile(
                              leading: Icon(
                                Icons.multitrack_audio_rounded,
                                color: Colors.amber[600],
                                size: 30,
                              ),
                              title: Text(
                                widget.map_data["Titre"].toString(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontFamily: "Circular",
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                widget.map_data["Verset"].toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: textColor().withOpacity(.8)),
                              ),
                              trailing: RotatedBox(
                                  quarterTurns: 1,
                                  child: IntrinsicHeight(
                                    child: Column(
                                      children: [
                                        Text(
                                          formatDurationStr(
                                                  widget.map_data["Duration"])
                                              .toString()
                                              .replaceAll(":", " : "),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  textColor().withOpacity(.7),
                                              fontFamily: "Circular"),
                                        ),
                                        SizedBox(
                                          width: 40,
                                          child: Divider(
                                            color: textColor().withOpacity(.5),
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                routeTransition(Enregistrement(
                                  widget.map_data,
                                  translate: true,
                                )));
                          },
                          child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      color: textColor(),
                                      fontSize: 17,
                                      fontFamily: "Circular",
                                      fontWeight: FontWeight.w400),
                                  children: [
                                WidgetSpan(
                                    child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(Icons.translate_rounded),
                                )),
                                TextSpan(text: "Traduire / Translate")
                              ])),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ExpansionTile(
                          tilePadding: EdgeInsets.symmetric(vertical: 0),
                          title: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      color: textColor(),
                                      fontSize: 17,
                                      fontFamily: "Circular",
                                      fontWeight: FontWeight.w400),
                                  children: [
                                WidgetSpan(
                                    child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(Icons.edit_note_rounded),
                                )),
                                TextSpan(text: "Modifier / Edit")
                              ])),
                          children: [
                            formulaire,
                            // getChamp("Titre", "Titre", 1),
                            // getChamp("Verset", "Versets Utilisé", 2),
                            // SizedBox(
                            //   height: 20,
                            // ),
                            CupertinoButton(
                                child: Text(
                                  "Valider modification",
                                  style: TextStyle(
                                      fontFamily: "Circular",
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue),
                                ),
                                onPressed: editBtn),
                            // Container(
                            //   decoration: BoxDecoration(
                            //       color: Colors.white,
                            //       borderRadius: BorderRadius.circular(7)),
                            //   child: CupertinoDialogAction(
                            //     onPressed: ,
                            //     child: Text("Valider Modification"),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: click_sup,
                          child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      color: conf ? Colors.red : textColor(),
                                      fontSize: 17,
                                      fontFamily: "Circular",
                                      fontWeight: FontWeight.w400),
                                  children: [
                                WidgetSpan(
                                    child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(CupertinoIcons.trash_fill),
                                )),
                                TextSpan(
                                    text: conf
                                        ? "Confirmer Supression " + rest
                                        : "Supprimer / Delete")
                              ])),
                        ),
                        // Container(
                        //   decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(7)),
                        //   child: CupertinoDialogAction(
                        //     onPressed: click_sup,
                        //     child: Text(conf
                        //         ? "Confirmer la supression " + rest
                        //         : "Supprimer " + rest),
                        //     isDestructiveAction: true,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                )),
    );
  }

  String formatDurationStr(String duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";

      return "0$n";
    }

    var t = duration.split(":").map((e) => int.parse(e)).toList();
    if (t.length < 2) {
      return duration;
    }

    String hours = twoDigits(t[0]);
    String minutes = twoDigits(t[1]);
    String seconds = twoDigits(t[2]);
    if (t[0] == 0) {
      return "$minutes:$seconds";
    }
    return "$hours:$minutes:$seconds";
  }
}
