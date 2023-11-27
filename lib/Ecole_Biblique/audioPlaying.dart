import 'dart:io';
import 'dart:math';
import 'dart:ui';

// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:cupertino_progress_bar/cupertino_progress_bar.dart';
import 'package:eglise_de_ville/Ecole_Biblique/SingleAudioPlaying.dart';
import 'package:eglise_de_ville/Ecole_Biblique/bard_player.dart';
import 'package:eglise_de_ville/api_operation_laravel.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/serveur_custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'cus.dart';
// import 'package:just_audio_cache/just_audio_cache.dart' as ja;

class AudioPlaying extends StatefulWidget {
  Map<String, dynamic> map_data;

  AudioPlaying({required this.map_data});

  @override
  State<AudioPlaying> createState() => _AudioPlayingState(this.map_data);
}

class _AudioPlayingState extends State<AudioPlaying> {
  Map<String, dynamic> map_data;

  String? selectedLangue = null;

  String file_path = "";
  bool isLoading = true;
  // ap.AudioPlayer audioPlayer = ap.AudioPlayer();
  _AudioPlayingState(this.map_data) {
    map_data = dupliquer([map_data]).first;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback(
      (_) {
        // Execute callback if page is mounted
        if (mounted) chargement();
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
//    playerController.dispose();

    super.dispose();
  }

  Future<void> chargement() async {
    //   FileInfo fileInfo = await showCupertinoModalPopup(
    //       context: context,
    //       barrierDismissible: false,
    //       filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
    //       builder: (context) => DownloadModal(serveur_ev + map_data["Url"]));

    // setState(() {
    //   file_path = fileInfo.file.path;
    // });
    // await fsPayer.openPlayer();
    // await preparePlaying();
    setState(() {
      isLoading = false;
    });
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

  void changeLangue(v) {
    setState(() {
      isLoading = true;
    });
    if ((selectedLangue ?? map_data["Langue"].toString().trim()) != v) {
      setState(() {
        selectedLangue = v.toString();
      });
      var target = null;
      for (var map in map_data["Langues"]) {
        if (map["Langue"].toString() == selectedLangue) {
          target = map;
          target["Langues"] = map_data["Langues"];
          target["LanguesIDs"] = map_data["LanguesIDs"];
          break;
        }
      }
      if (target != null) {
        setState(() {
          map_data = target;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: themeData,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 1,
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
              )
            ],
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Colors.red,
                )),

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
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: isLoading
                ? Center(
                    child: CupertinoActivityIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                          child: Container(
                        height: double.infinity,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
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
                                    map_data["Titre"].toString(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontFamily: "Circular",
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    map_data["AuthorName"].toString(),
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
                                                      map_data["Duration"])
                                                  .toString()
                                                  .replaceAll(":", " : "),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor()
                                                      .withOpacity(.7),
                                                  fontFamily: "Circular"),
                                            ),
                                            SizedBox(
                                              width: 50,
                                              child: Divider(
                                                color:
                                                    textColor().withOpacity(.5),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 30),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Versets Utilisés".toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: "Circular",
                                            fontWeight: FontWeight.w600),
                                      ),
                                      FutureBuilder<List<Map<String, dynamic>>>(
                                        future: getLangues(context),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            List<Map<String, dynamic>>
                                                languesToShow = [];
                                            for (var item in snapshot.data!) {
                                              if (map_data["LanguesIDs"]
                                                  .contains(item['id'])) {
                                                languesToShow.add(item);
                                              } else {
                                                print(
                                                    "cash no ${map_data["LanguesIDs"]} && ${item['id']}");
                                              }
                                            }

                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  border: Border.all(
                                                      color: isDark()
                                                          ? Colors.white24
                                                          : Colors.grey[200]!)),
                                              child: DropdownButton(
                                                  value: selectedLangue ??
                                                      map_data["Langue"]
                                                          .toString()
                                                          .trim(),
                                                  underline: SizedBox(),
                                                  isExpanded: false,
                                                  icon: Icon(
                                                    CupertinoIcons.volume_up,
                                                    size: 15,
                                                  ),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: "Circular",
                                                      color: textColor(),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                  items: languesToShow.map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (var langue) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: langue['id']
                                                          .toString(),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(right: 5),
                                                        child:
                                                            Text(langue['nom']),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (v) {
                                                    changeLangue(v);
                                                  }),
                                            );
                                          }
                                          return CupertinoActivityIndicator();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    // VerticalDivider(
                                    //   thickness: 5,
                                    //   color: textColor().withOpacity(.3),
                                    //   width: 5,
                                    // ),
                                    // SizedBox(
                                    //   width: 10,
                                    // ),
                                    Flexible(
                                      child: Container(
                                        width: double.infinity,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        child: Text(
                                          map_data["Verset"].toString(),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontFamily: "Circular",
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),

                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: AudioPlayerWidget(
                              audioUrl: map_data['UrlAsset'].toString())),

                      // Flexible(
                      //     child: Container(
                      //   width: double.infinity,
                      //   height: double.infinity,
                      // )),

                      // SizedBox(
                      //   width: double.infinity,
                      //   child: DownloadModal(
                      //       "https://mp3ringtonesdownload.net/wp-content/uploads/2021/04/best-is-qadar-ringtone-download-mp3-tulsi-kumar-darshan-raval.mp3"),
                      // )
                    ],
                  ),
          ),
        ));
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
      //return "0$n";
    }

    String hours = twoDigits(duration.inHours.remainder(24));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours.remainder(24) == 0) {
      return "$minutes:$seconds";
    }
    return "$hours:$minutes:$seconds";
  }
}
