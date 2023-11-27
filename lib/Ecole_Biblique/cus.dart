import 'dart:ui';
import 'dart:io' as io;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cupertino_progress_bar/cupertino_progress_bar.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/progressbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PlayerController playerController;

  final sources = [
    'https://www.mboxdrive.com/m54.mp3',
    'https://www.mboxdrive.com/%c3%86STRAL%20-%20half%20light.mp3',
    'https://www.mboxdrive.com/%ca%8f%e1%b4%80%20%ca%99%e1%b4%9c%e1%b4%85%e1%b4%9c.mp3'
  ];
  bool isload = false;
  @override
  void initState() {
    super.initState();
    // download();
  }

  download() async {
    setState(() {
      isload = true;
    });
    var file = await DefaultCacheManager().getSingleFile(
      "https://mp3ringtonesdownload.net/wp-content/uploads/2020/02/tik-tok-background-music.mp3",
    );
    setState(() {
      isload = false;
    });
    playerController = new PlayerController();
    //playerController.setRefresh(true);
    await playerController.preparePlayer(path: file.path);
    playerController.startPlayer();

    // print("mduration $maxDuration ${playerController.maxDuration}");
    // var t = await playerController.extractWaveformData(path: file_path);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              isload ? CupertinoActivityIndicator() : SizedBox(),
              Center(
                  child: MaterialButton(
                onPressed: () {},
                child: Text("Télécharger"),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class DownloadModal extends StatefulWidget {
  String url;
  DownloadModal(this.url);

  @override
  State<DownloadModal> createState() => _DownloadModalState(this.url);
}

class _DownloadModalState extends State<DownloadModal> {
  String url;
  _DownloadModalState(this.url);
  double percentage = 0;
  Stream<FileResponse>? stream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    url = url.replaceAll("/storage//storage/", "/storage/");
    url = url.replaceAll("/storage/storage/", "/storage/");

    DefaultCacheManager()
        .getFileStream(url, withProgress: true)
        .listen((event) {
      if (event is DownloadProgress) {
        DownloadProgress pg = event;
        setState(() {
          percentage = pg.progress ?? 0;
        });
      } else {
        setState(() {
          percentage = 1;
        });
        late FileInfo b = event as FileInfo;

        DefaultCacheManager()
            .putFile(url, b.file.readAsBytesSync(),
                key: url, maxAge: Duration(days: 365))
            .then((value) {
          Navigator.pop(context, event);
        });
      }
    });
  }

  // download() async {
  //   DefaultCacheManager()
  //       .getFileStream(
  //           "https://mp3ringtonesdownload.net/wp-content/uploads/2020/02/tik-tok-background-music.mp3",
  //           withProgress: true)
  //       .listen((event) {
  //     setState(() {});
  //   });
  //   var file = await DefaultCacheManager().getSingleFile();
  // }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: AlertDialog(
        content: IntrinsicHeight(
          child: Column(
            children: [
              Text(
                "Téléchargement ...",
                style: TextStyle(
                    fontFamily: "Circular", fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Text("${(percentage * 100).toInt()} %"),
              SizedBox(
                height: 20,
              ),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: true
                      ? CupertinoProgressBar(
                          value: percentage,
                        )
                      : MyProgressBar(
                          height: 25,
                          colors: [
                            Colors.orange,
                            Colors.red,
                          ],
                          percentage: percentage,
                          maxWidth: MediaQuery.of(context).size.width * .5),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
