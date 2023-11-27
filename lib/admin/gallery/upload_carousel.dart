import 'dart:convert';
import 'dart:io';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:overlay_support/overlay_support.dart';
import 'package:file_picker/file_picker.dart' as fp;

class UploadGIFCarousel extends StatefulWidget {
  UploadGIFCarousel();
  @override
  _UploadGIFCarouselState createState() => _UploadGIFCarouselState();
}

class _UploadGIFCarouselState extends State<UploadGIFCarousel> {
  List<Map<String, dynamic>> list_image = [];
  bool isuploading = false;
  bool isload = false;
  // FlutterVideoCompress _flutterVideoCompress = FlutterVideoCompress();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargement();
  }

  file_choice() async {
    try {
      fp.FilePickerResult? result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['gif'],
      );

      if (result != null && result.files.single.path != null) {
        File image = File(result.files.single.path.toString());
        // if (result.files.single.path.toString().split(".").last.toLowerCase() !=
        //         "gif" &&
        //     (Platform.isAndroid || Platform.isIOS)) {
        //   final file = await _flutterVideoCompress.convertVideoToGif(
        //     image.path,
        //     startTime: 0, // default(0)
        //     // duration: 5, // default(-1)
        //     // endTime: -1 // default(-1)
        //   );
        //   debugPrint(file.path);
        //   if (file != null) {
        //     image = file;
        //   }
        // } else if (result.files.single.path
        //         .toString()
        //         .split(".")
        //         .last
        //         .toLowerCase() !=
        //     "gif") {
        //   showSimpleNotification(
        //       Text("Seulement les fichiers GIF sont autorié"));
        //   return;
        // }

        // File image = File(result.files.single.path.toString());
        showModalBottomSheet(
            backgroundColor: Colors.transparent,
            elevation: 0,
            isDismissible: false,
            context: context,
            builder: (context) {
              return BottomImgSend(image);
            }).then((value) {
          chargement();
        });
      }
    } catch (e) {
      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return AlertDialog(
      //       title: Text("Erreur sélection"),
      //       content: Text(e.toString()),
      //     );
      //   },
      // );
    }
  }

  void chargement() async {
    setState(() {
      isload = true;
      list_image = [];
    });
    var t = await select_data("SELECT * from Gallery_Carousel ");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_image = t;
      });
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage("Erreur", t[0]["error"].toString(), context);
    }
    setState(() {
      isload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDatalight,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xfffafafa),
        appBar: AppBar(
          backgroundColor: Color(0xfffafafa),
          elevation: 2,
          centerTitle: true,
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
                style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Flexible(
                  child: Container(
                width: double.infinity,
                height: double.infinity,
                child: isload
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        itemCount: list_image.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15,
                            crossAxisSpacing: 15),
                        itemBuilder: (context, int index) {
                          return InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  isDismissible: true,
                                  context: context,
                                  builder: (context) {
                                    return BotoomSend2(list_image[index]);
                                  }).then((value) {
                                chargement();
                              });
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: get_cached_image(
                                list_image[index]["Lien"].toString(),
                              ),
                            ),
                          );
                        }),
              )),
              SizedBox(
                height: 10,
              ),
              ButtonTheme(
                minWidth: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    color: Colors.red[700], //Color(0xff00C600),
                    textColor: Colors.white,
                    onPressed: file_choice,
                    elevation: 0,
                    icon: Icon(CupertinoIcons.photo_camera_solid),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text("Ajouter"),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BottomImgSend extends StatefulWidget {
  File image;
  BottomImgSend(this.image);

  @override
  _BottomImgSendState createState() => _BottomImgSendState();
}

class _BottomImgSendState extends State<BottomImgSend> {
  bool isuploading = false;
  Future<String> send_file(String filename, String url, String requete) async {
    File fichier = File(filename);
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);
    request.files.add(http.MultipartFile(
        'fileToUpload', fichier.readAsBytes().asStream(), fichier.lengthSync(),
        filename: fichier.path.split('/').last));

    request.fields['json'] = requete;
    request.persistentConnection = true;

    var res = await request.send();

    var aret;
    await res.stream.transform(utf8.decoder).listen((value) {
      // print("strd " + value);
      aret = value;
    });
    print("resppp : $aret");
    return aret;
    // showinformation("Réussi", "Le fichier a été envoyé avec succès");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Flexible(
              child: Container(
            width: double.infinity,
            height: double.infinity,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(widget.image.path),
                  fit: BoxFit.cover,
                )),
          )),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Flexible(
                child: ButtonTheme(
                  minWidth: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: RaisedButton(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(100)),
                      textColor: Colors.grey[900],
                      onPressed: () {
                        // Navigator.pop(context);
                        Clipboard.setData(ClipboardData(text: "your text"));
                      },
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Text("Annuler"),
                      )),
                ),
              ),
              SizedBox(
                width: 7,
              ),
              Flexible(
                  child: isuploading
                      ? Center(
                          child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(Colors.orange[700]),
                        ))
                      : ButtonTheme(
                          minWidth: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              color: Color(0xff00C600),
                              textColor: Colors.white,
                              onPressed: () async {
                                setState(() {
                                  isuploading = true;
                                });

                                var rep = await send_file(
                                    widget.image.path,
                                    server_up_img_carousel,
                                    jsonEncode(
                                        {'Date': DateTime.now().toString()}));
                                setState(() {
                                  isuploading = false;
                                });
                                print("resppppp $rep");
                                Navigator.pop(context);
                              },
                              elevation: 0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                child: Text("Envoyer"),
                              )),
                        ))
            ],
          )
        ],
      ),
    );
  }
}

class BotoomSend2 extends StatefulWidget {
  Map<String, dynamic> map = {};
  BotoomSend2(this.map);

  @override
  _BotoomSend2State createState() => _BotoomSend2State();
}

class _BotoomSend2State extends State<BotoomSend2> {
  bool isuploading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Flexible(
              child: Container(
            width: double.infinity,
            height: double.infinity,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: get_cached_image(widget.map["Lien"])),
          )),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Flexible(
                child: ButtonTheme(
                  minWidth: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: RaisedButton(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(100)),
                      textColor: Colors.grey[900],
                      onPressed: () {
                        Navigator.pop(context);

                        Clipboard.setData(
                            ClipboardData(text: widget.map["Lien"].toString()));
                        showSimpleNotification(
                            Text(
                                "Le lien de l'image a été dans le press-papier \n" +
                                    widget.map["Lien"].toString() +
                                    "\n"),
                            duration: Duration(seconds: 5),
                            slideDismiss: true,
                            background: Color(0xff00C600));
                      },
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Text("Copier le lien"),
                      )),
                ),
              ),
              SizedBox(
                width: 7,
              ),
              Flexible(
                  child: isuploading
                      ? Center(
                          child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(Colors.orange[700]),
                        ))
                      : ButtonTheme(
                          minWidth: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              color: Colors.red,
                              textColor: Colors.white,
                              onPressed: () async {
                                setState(() {
                                  isuploading = true;
                                });
                                var r = await exec_mysql_query(
                                    "DELETE From Gallery_Carousel WHERE id='" +
                                        widget.map["id"].toString() +
                                        "' ");
                                print("reponse $r");
                                setState(() {
                                  isuploading = false;
                                });
                                Navigator.pop(context);
                              },
                              elevation: 0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                child: Text("Supprimer"),
                              )),
                        ))
            ],
          )
        ],
      ),
    );
  }
}
