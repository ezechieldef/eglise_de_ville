import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:eglise_de_ville/Ecole_Biblique/gpt.dart';
import 'package:eglise_de_ville/const_notification.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/serveur_custom.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:audio_waveforms_fix/audio_waveforms.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../api_operation_laravel.dart';
// import 'package:dio/dio.dart' as dio;

// import 'package:multipart_request/multipart_request.dart' as mp;

class Enregistrement extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  bool translate;
  Enregistrement(Map<String, dynamic> k, {this.translate = false}) {
    if (k.isEmpty) {
      map_data = {"Titre": "", "Verset": "", "Langue": null};
    } else {
      map_data = k;
    }
  }

  @override
  State<Enregistrement> createState() => _EnregistrementState(this.map_data);
}

class _EnregistrementState extends State<Enregistrement> {
  List<Map<String, dynamic>> _langues = [];
  String? _selectedLangue = null;
  late MyForm formulaire;
  late Map<String, dynamic> map_data;
  _EnregistrementState(this.map_data);
  Map<String, dynamic> file_upload = {
    "maxSize": 0,
    "progress": 0,
    "uploadedSize": 0,
    "message": ""
  };
  late RecorderController recorderController;
  late PlayerController playerController;
  Widget playingWidget = SizedBox();
  Duration? maxDuration, elapsedDuration;
  List<double> waves = [];
  String file_path = "";
  IconData recordButtonIcon = Icons.mic;
  DateTime dateTime = DateTime(0);
  String time_disp = "";
  bool isPreparing = false;
  bool isLoading = false;
  // IconData pause = Icons.mic;
  void reload_time_str() {
    setState(() {
      time_disp =
          time_disp = formatDuration(recorderController.elapsedDuration);
    });
  }

  Future<void> preparePlaying() async {
    setState(() {
      isPreparing = true;
      waves = [];
      maxDuration == null;
      elapsedDuration == null;
    });
    if (!playerController.isDisposed) {
      setState(() {
        playerController.dispose();
      });
    }
    playerController = new PlayerController();
    //playerController.setRefresh(true);
    await playerController.preparePlayer(path: file_path);

    setState(() {
      maxDuration = Duration(milliseconds: playerController.maxDuration);
    });
    print("mduration $maxDuration ${playerController.maxDuration}");
    var t = await playerController.extractWaveformData(path: file_path);

    setState(() {
      waves = t;
      playingWidget = AudioFileWaveforms(
        enableSeekGesture: true,
        continuousWaveform: false,
        size: Size(MediaQuery.of(context).size.width, 200.0),
        playerController: playerController,
      );
      playerController.onCurrentDurationChanged.listen((event) {
        setState(() {
          elapsedDuration = Duration(milliseconds: event);
        });
      });
      isPreparing = false;
    });
  }

  void reinitialiser() {
    setState(() {
      file_path = "";
      waves = [];
      elapsedDuration = null;
      maxDuration = null;
      playerController.stopAllPlayers();
      recorderController.stop();
      recordButtonIcon = Icons.mic_rounded;
    });
  }

  void redobtn() {
    showCupertinoModalPopup(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        context: context,
        builder: (context) {
          return Theme(
            data: themeData,
            child: AlertDialog(
              content: IntrinsicHeight(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                          "Confirmez-vous la supression de cet enregistrement ?"),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          maxDuration == null
                              ? time_disp
                              : formatDuration(maxDuration!),
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: textColor().withOpacity(.2),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(
                                  5), // Remplacez la valeur 10 par le rayon souhaité
                            ),
                            child: Text("Annuler"),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          MaterialButton(
                            onPressed: () {
                              reinitialiser();
                              Navigator.pop(context);
                            },
                            color: Colors.red,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  5), // Remplacez la valeur 10 par le rayon souhaité
                            ),
                            child: Text("Supprimer"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void playingbtn() async {
    print("state playing btn ${playerController.playerState} ");

    switch (playerController.playerState) {
      case PlayerState.initialized:
        playerController.startPlayer(finishMode: FinishMode.loop);
        setState(() {
          recordButtonIcon = Icons.pause_rounded;
        });
        break;
      case PlayerState.playing:
        playerController.pausePlayer();
        setState(() {
          recordButtonIcon = Icons.play_arrow_rounded;
        });
        break;
      case PlayerState.paused:
        playerController.startPlayer(finishMode: FinishMode.loop);
        setState(() {
          recordButtonIcon = Icons.pause_rounded;
        });
        break;
      case PlayerState.stopped:
        playerController.startPlayer(finishMode: FinishMode.loop);
        setState(() {
          recordButtonIcon = Icons.pause_rounded;
        });
        break;
      default:
        await preparePlaying();
        playerController.startPlayer(finishMode: FinishMode.loop);
        setState(() {
          recordButtonIcon = Icons.pause_rounded;
        });
    }
    playerController.onCompletion.listen((event) {
      setState(() {
        playerController.pausePlayer();
        elapsedDuration = Duration(milliseconds: 0);
        playerController.seekTo(0);
        setState(() {
          recordButtonIcon = Icons.play_arrow_rounded;
        });
      });
    });

    print("state playing btn 2 ${playerController.playerState} ");
  }

  @override
  void initState() {
    super.initState();
    formulaire = MyForm(map_data);
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100
      ..bitRate = 48000;

    playerController = PlayerController();

    recorderController.addListener(() {
      reload_time_str();
    });
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) {
        // Execute callback if page is mounted
      },
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String hours = twoDigits(duration.inHours.remainder(24));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }

  void recordPause() async {
    if (recorderController.isRecording) {
      await recorderController.pause();
    }
    setState(() {
      recordButtonIcon = Icons.play_arrow_rounded;
    });
  }

  void recordButtontap() async {
    if (!file_path.isEmpty) {
      playingbtn();
      return;
    }
    setState(() {
      try {
        playerController.dispose();
        playerController.stopAllPlayers();
      } catch (e) {}
    });
    IconData ste = Icons.mic_rounded;
    setState(() {
      waves = [];
      maxDuration == null;
      elapsedDuration == null;
    });
    switch (recorderController.recorderState) {
      case RecorderState.recording:
        //recorderController.setScrolledPostionDuration(0);
        var tfile_path = (await recorderController.stop()).toString();
        setState(() {
          recordButtonIcon = Icons.mic_rounded;
          recordButtonIcon = Icons.play_arrow_rounded;
        });
        setState(() {
          file_path = tfile_path;
        });

        await preparePlaying();

        break;

      default:
        await recorderController.record();
        setState(() {
          recordButtonIcon = Icons.stop_rounded;
        });
        break;
    }
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
                style: TextStyle(color: textColor(), fontFamily: "Montserrat"),
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
        body: WillPopScope(
          onWillPop: () async {
            if (file_path.isNotEmpty) {
              return await showCupertinoModalPopup(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return Theme(
                      data: themeData,
                      child: AlertDialog(
                        title: Text("Alerte"),
                        actions: [
                          MaterialButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: textColor().withOpacity(.2),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(
                                  5), // Remplacez la valeur 10 par le rayon souhaité
                            ),
                            child: Text("Revenir"),
                          ),
                          MaterialButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            color: Colors.red,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  5), // Remplacez la valeur 10 par le rayon souhaité
                            ),
                            child: Text("Supprimer"),
                          ),
                        ],
                        content: IntrinsicHeight(
                          child: Container(
                            width: double.infinity,
                            child: Text(
                              "Votre enregistrement non sauvegardé sera supprimé ",
                              style: TextStyle(fontFamily: 'Circular'),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).then((value) => value);
            }
            return true;
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // SizedBox(
                  //     // height: 100,
                  //     width: double.infinity,
                  //     child: langueWidget()),
                  // getChamp("Titre", "Titre", 1),
                  // getChamp("Verset", "Versets Utilisé", 3),
                  (widget.translate)
                      ? Column(
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
                                              formatDurationStr(widget
                                                      .map_data["Duration"])
                                                  .toString()
                                                  .replaceAll(":", " : "),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor()
                                                      .withOpacity(.7),
                                                  fontFamily: "Circular"),
                                            ),
                                            SizedBox(
                                              width: 40,
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
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Traduction / Translating",
                              style: TextStyle(
                                  fontFamily: "Circular",
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 20,
                  ),
                  formulaire,
                  SizedBox(
                    height: 20,
                  ),
                  file_path.isEmpty
                      ? Container(
                          color: Colors.grey.withOpacity(.2),
                          child: AudioWaveforms(
                            shouldCalculateScrolledPosition: true,
                            enableGesture: true,
                            size: Size(MediaQuery.of(context).size.width, 70),
                            recorderController: recorderController,
                          ))
                      : isPreparing
                          ? SizedBox(
                              width: double.infinity,
                              height: 70,
                              child: Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            )
                          : GestureDetector(
                              onTapUp: (TapUpDetails details) async {
                                RenderBox box =
                                    context.findRenderObject() as RenderBox;
                                Offset localPosition =
                                    box.globalToLocal(details.globalPosition);
                                Size size = box.size;
                                int dureeChoisi =
                                    ((localPosition.dx / size.width) *
                                            maxDuration!.inMilliseconds)
                                        .toInt();

                                setState(() {
                                  playerController
                                      .seekTo((dureeChoisi).toInt());
                                  elapsedDuration =
                                      Duration(milliseconds: dureeChoisi);
                                });

                                // Gérez le pourcentage du clic comme vous le souhaitez
                                print(
                                    'Pourcentage $dureeChoisi du clic :  total ${maxDuration!.inMilliseconds} ');
                              },
                              child: Container(
                                color: Colors.grey.withOpacity(.2),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Opacity(
                                  opacity: .4,
                                  child: RectangleWaveform(
                                    samples: waves,
                                    height: 70,
                                    width: MediaQuery.of(context).size.width,

                                    inactiveColor: textColor(),
                                    activeColor: Colors.red,
                                    activeBorderColor: Colors.red,
                                    inactiveBorderColor: textColor(),
                                    isRoundedRectangle: true,
                                    // invert: true,
                                    isCentered: true,
                                    maxDuration: maxDuration == null ||
                                            elapsedDuration == null
                                        ? null
                                        : maxDuration,

                                    elapsedDuration: maxDuration == null ||
                                            elapsedDuration == null
                                        ? null
                                        : elapsedDuration,
                                  ),
                                ),
                              ),
                            ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      (file_path.isEmpty || maxDuration == null)
                          ? time_disp
                          : formatDuration(maxDuration!),
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Opacity(
                        opacity: (!file_path.isEmpty ||
                                recorderController.recorderState !=
                                    RecorderState.recording)
                            ? 0.3
                            : 1,
                        child: IconButton(
                            onPressed: recorderController.isRecording
                                ? recordPause
                                : null,
                            icon: Icon(
                              // Icons.mic,
                              Icons.pause_rounded,
                              color: textColor().withOpacity(0.5),
                              size: 40,
                            )),
                      ),
                      InkWell(
                        onTap: recordButtontap,
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 1, color: Colors.grey)),
                          padding: EdgeInsets.all(5),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xffE76161),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              recordButtonIcon,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: file_path.isEmpty ? 0.3 : 1,
                        child: IconButton(
                          onPressed: file_path.isEmpty ? null : redobtn,
                          icon: Icon(
                            Icons.delete_rounded,
                            // color: Colors.white,
                            color: textColor().withOpacity(0.5),
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(5),
                    //     border: Border.all(width: 2, color: Colors.grey)),
                    child: MaterialButton(
                      onPressed: (formulaire.getFormData() == null ||
                              file_path.isEmpty)
                          ? null
                          : btnEnvoyerClick,
                      minWidth: double.infinity,
                      color: Colors.red,
                      textColor: Colors.white,
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(
                      //       10), // Remplacez la valeur 10 par le rayon souhaité
                      // ),
                      child: Text("ENVOYER"),
                    ),
                  )
                  // IconButton(onPressed: playingbtn, icon: Icon(Icons.circle))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget menuBouton(Widget icon, String text) {
    return IntrinsicHeight(
      child: Column(
        children: [
          icon,
          SizedBox(
            height: 10,
          ),
          Text(
            text.toUpperCase(),
            style: TextStyle(
                color: textColor().withOpacity(.8),
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget getChamp(String var_name, String desc, int minL) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              camelCase(desc),
              style: TextStyle(
                  fontFamily: "Circular", fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 7,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.3),
                  borderRadius: BorderRadius.circular(7)),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: TextFormField(
                initialValue: map_data[var_name],
                decoration: InputDecoration(border: InputBorder.none),
                minLines: minL,
                maxLines: minL,
                // style: TextStyle(fontSize: 20),
                onChanged: (v) {
                  setState(() {
                    map_data.update(var_name, (value) => v.toString().trim());
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  btnEnvoyerClick() async {
    var temp = formulaire.getFormData();
    if (temp == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Vous devez d'abord remplir le formulaire"),
        backgroundColor: Colors.red,
      ));
      return;
    } else if (temp.containsValue(null) || temp.containsValue("")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Vous devez d'abord remplir le formulaire"),
        backgroundColor: Colors.red,
      ));
    }

    temp.forEach((key, valuer) {
      setState(() {
        map_data.update(key, (value) => valuer);
      });
    });

    showCupertinoModalPopup(
        context: context,
        barrierDismissible: false,
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        builder: (context) => Theme(
              data: themeData,
              child: AlertDialog(
                content: Container(
                    height: 200,
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    )),
              ),
            ));
    await faireRequetePost();
    setState(() {
      map_data = {"Titre": "", "Verset": "", "Langue": ""};
    });
    Navigator.pop(context);
    Navigator.pop(context, true);
    //ScaffoldMessenger.of(context).showSnackBar(Sn)
    //showMessage("", mess, context)
    showNotif(context, "Envoi réussi ! ", CupertinoColors.activeGreen);
  }

  Future<void> faireRequetePost() async {
    var url = Uri.parse(serveur_ecole_biblique);
    var request = http.MultipartRequest('POST', url);

    // Ajoutez les données à la requête
    request.fields['Langue'] = map_data["Langue"].toString();
    request.fields['Email'] = connected_user["email"].toString();
    request.fields['Titre'] = map_data["Titre"].toString();
    request.fields['Verset'] = map_data["Verset"].toString();
    request.fields['Duration'] = formatDuration(maxDuration!);
    request.fields['translate'] = "${widget.translate}";
    if (widget.translate) {
      request.fields['Reference'] = "${widget.map_data['id']}";
    }
    // Ajoutez les fichiers à la requête
    print("listeninh " + request.fields.toString());
    // return;
    var file1 = await http.MultipartFile.fromPath('Url', file_path);
    request.files.add(file1);

    // Envoyez la requête et récupérez la réponse
    var response = await request.send();
    var responseStream = await response.stream.toBytes();

// Convertir le flux de réponse en une chaîne de caractères
    var responseString = String.fromCharCodes(responseStream);
    print("listeninh repstr $responseString");
    // response.stream.listen((value) {
    //   try {
    //     var jr = jsonDecode(String.fromCharCodes(value));
    //     print("listeninh resp $jr");
    //     if (jr["status"] == "0") {
    //       setState(() {
    //         file_upload.update("message", (value) => "Envoi réussi !");
    //       });
    //     }
    //   } catch (e) {
    //     setState(() {
    //       file_upload.update("message", (value) => "Echec de l'envoi !");
    //     });
    //   }
    // });
    // Vérifiez le statut de la réponse

    // if (response.statusCode == 200) {
    //   setState(() {
    //     file_upload.update("message", (value) => "Envoi réussi !");
    //   });
    //   print('Requête réussie');
    // } else {
    //   setState(() {
    //     file_upload.update("message", (value) => "Echec de l'envoi !");
    //   });
    //   print('Échec de la requête');
    // }
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
