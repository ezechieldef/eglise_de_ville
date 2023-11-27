// import 'dart:math';

// import 'package:eglise_de_ville/contante_var2.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sound/public/flutter_sound_player.dart';

// class SingleAudioPlayingWidget extends StatefulWidget {
//   Map<String, dynamic> map_data;
//   SingleAudioPlayingWidget(this.map_data);

//   @override
//   State<SingleAudioPlayingWidget> createState() =>
//       _SingleAudioPlayingWidgetState(/*this.map_data*/);
// }

// class _SingleAudioPlayingWidgetState extends State<SingleAudioPlayingWidget> {
//   // Map<String, dynamic> map_data;
//   final fsPayer = FlutterSoundPlayer();

//   // late PlayerController playerController;
//   IconData recordButtonIcon = Icons.play_arrow_rounded;
//   Duration? maxDuration = Duration.zero;
//   Duration? elapsedDuration = Duration.zero;
//   List<double> waves = [];

//   String file_path = "";
//   bool isLoading = false;
//   // ap.AudioPlayer audioPlayer = ap.AudioPlayer();
//   _SingleAudioPlayingWidgetState(/*this.map_data*/) {
//     // file_path = widget.map_data["UrlAsset"].toString();
//     // maxDuration = Duration.zero;
//     // elapsedDuration = Duration.zero;
//   }
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     //  playerController.dispose();
//     fsPayer.closePlayer();

//     super.dispose();
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     WidgetsBinding.instance?.addPostFrameCallback(
//       (_) {
//         // Execute callback if page is mounted
//         setState(() {
//           file_path = widget.map_data["UrlAsset"].toString();
//           maxDuration = Duration.zero;
//           elapsedDuration = Duration.zero;
//         });
//       },
//     );
//   }

//   Future<void> preparePlaying() async {
//     setState(() {
//       file_path = widget.map_data["UrlAsset"];
//       maxDuration = Duration.zero;

//       elapsedDuration = Duration.zero;
//     });
//     setState(() {
//       isLoading = true;
//     });
//     // Initialisation du lecteur
//     if (!fsPayer.isOpen()) {
//       await fsPayer.openPlayer();
//     }

//     // Commencer à charger le fichier audio
//     if (mounted) {
//       setState(() {
//         isLoading = true;
//       });
//     }

//     // Charger le fichier audio

//     await fsPayer.setSubscriptionDuration(Duration(milliseconds: 100));

//     final maxDurationPlayer = await fsPayer.startPlayer(
//       fromURI: file_path,
//     );

//     if (mounted) {
//       setState(() {
//         this.maxDuration = maxDurationPlayer;
//         recordButtonIcon = Icons.pause_rounded;
//         isLoading = false;
//       });
//     }

//     // Suivre les changements de la durée actuelle pendant la lecture
//     fsPayer.onProgress?.listen((e) async {
//       if (mounted) {
//         setState(() {
//           elapsedDuration = Duration(milliseconds: e.position.inMilliseconds);
//         });
//       }
//       if (fsPayer.isStopped) {
//         // await fsPayer.pausePlayer();
//         setState(() {
//           elapsedDuration = Duration(milliseconds: 0);
//           fsPayer.seekToPlayer(Duration(milliseconds: 0));
//           recordButtonIcon = Icons.play_arrow_rounded;
//         });
//       }
//       // if (maxDuration!.inSeconds == elapsedDuration!.inSeconds) {

//       // }
//     });
//     setState(() {
//       isLoading = false;
//     });
//   }

//   String formatDurationStr(String duration) {
//     String twoDigits(int n) {
//       if (n >= 10) return "$n";

//       return "0$n";
//     }

//     var t = duration.split(":").map((e) => int.parse(e)).toList();
//     if (t.length < 2) {
//       return duration;
//     }

//     String hours = twoDigits(t[0]);
//     String minutes = twoDigits(t[1]);
//     String seconds = twoDigits(t[2]);
//     if (t[0] == 0) {
//       return "$minutes:$seconds";
//     }
//     return "$hours:$minutes:$seconds";
//   }

//   String formatDuration(Duration duration) {
//     String twoDigits(int n) {
//       if (n >= 10) return "$n";
//       return "0$n";
//       //return "0$n";
//     }

//     String hours = twoDigits(duration.inHours.remainder(24));
//     String minutes = twoDigits(duration.inMinutes.remainder(60));
//     String seconds = twoDigits(duration.inSeconds.remainder(60));
//     if (duration.inHours.remainder(24) == 0) {
//       return "$minutes:$seconds";
//     }
//     return "$hours:$minutes:$seconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//           vertical: MediaQuery.of(context).size.height * 0.01, horizontal: 10),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: isDark()
//               ? [
//                   BoxShadow(
//                       offset: Offset(0, -4),
//                       color: Colors.white.withOpacity(.3))
//                 ]
//               : [
//                   BoxShadow(
//                       color: Colors.grey[200]!,
//                       offset: Offset(4, 4),
//                       blurRadius: 10)
//                 ],
//           color: isDark() ? Colors.white.withOpacity(.3) : Colors.white),
//       child: IntrinsicHeight(
//         child: Column(
//           children: [
//             isLoading
//                 ? Center(
//                     child: CupertinoActivityIndicator(),
//                   )
//                 : SizedBox(
//                     height: 10,
//                   ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   elapsedDuration == null
//                       ? "00:00"
//                       : formatDuration(elapsedDuration!).toString(),
//                   style: TextStyle(
//                     fontFamily: "Circular",
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   maxDuration == null
//                       ? "00:00"
//                       : formatDuration(maxDuration!).toString(),
//                   style: TextStyle(
//                     fontFamily: "Circular",
//                     fontWeight: FontWeight.bold,
//                   ),
//                 )
//               ],
//             ),
//             (!fsPayer.isOpen() || maxDuration == null)
//                 ? SizedBox()
//                 : Padding(
//                     padding: const EdgeInsets.only(bottom: 5),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: 5),
//                       child: Opacity(
//                           opacity: .7,
//                           child: SliderTheme(
//                             data: SliderThemeData(
//                               trackHeight: 1,

//                               overlayShape: RoundSliderOverlayShape(
//                                   overlayRadius:
//                                       0), // Ajustez le rayon de l'overlay si nécessaire
//                               thumbShape: RoundSliderThumbShape(
//                                   enabledThumbRadius:
//                                       5), // Ajustez le rayon du pouce du Slider
//                               valueIndicatorShape:
//                                   PaddleSliderValueIndicatorShape(), // Utilisez PaddleSliderValueIndicatorShape pour ajuster le padding
//                             ),
//                             child: Slider(
//                                 max: maxDuration == null
//                                     ? 0
//                                     : maxDuration!.inSeconds.toDouble(),
//                                 value: elapsedDuration == null
//                                     ? 0
//                                     : elapsedDuration!.inSeconds.toDouble(),
//                                 onChanged: (v) async {
//                                   if (fsPayer.playerState ==
//                                       PlayerState.isStopped) {
//                                     await preparePlaying();
//                                   }
//                                   setState(() {
//                                     fsPayer.seekToPlayer(
//                                         Duration(seconds: v.toInt()));
//                                     elapsedDuration =
//                                         Duration(seconds: v.toInt());
//                                   });
//                                 }),
//                           )

//                           //  RectangleWaveform(
//                           //   samples: waves,
//                           //   height: 30,
//                           //   width: MediaQuery.of(context).size.width - 30,
//                           //   activeBorderColor: Colors.orange,
//                           //   inactiveBorderColor: textColor().withOpacity(0),
//                           //   inactiveColor: textColor().withOpacity(.2),
//                           //   activeColor: Colors.orange,

//                           //   isRoundedRectangle: true,
//                           //   // invert: true,
//                           //   isCentered: true,
//                           //   maxDuration: maxDuration == null ||
//                           //           elapsedDuration == null
//                           //       ? null
//                           //       : maxDuration,

//                           //   elapsedDuration: maxDuration == null ||
//                           //           elapsedDuration == null
//                           //       ? null
//                           //       : elapsedDuration,
//                           // ),
//                           ),
//                     ),
//                   ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SizedBox(),
//                 IconButton(
//                     onPressed: (elapsedDuration == null || maxDuration == null)
//                         ? null
//                         : () {
//                             setState(() {
//                               final dur = Duration(
//                                   seconds:
//                                       max(0, elapsedDuration!.inSeconds - 10));
//                               fsPayer.seekToPlayer(dur);
//                               elapsedDuration = dur;
//                             });
//                           },
//                     icon: Icon(Icons.fast_rewind_rounded)),
//                 IconButton(
//                     padding: EdgeInsets.zero,
//                     onPressed: playingbtn,
//                     icon: Icon(
//                       recordButtonIcon,
//                       size: 35,
//                       color: Colors.red,
//                     )),
//                 IconButton(
//                     onPressed: (elapsedDuration == null || maxDuration == null)
//                         ? null
//                         : () {
//                             setState(() {
//                               final dur = Duration(
//                                   seconds: min(maxDuration!.inSeconds,
//                                       elapsedDuration!.inSeconds + 10));
//                               fsPayer.seekToPlayer(dur);
//                               elapsedDuration = dur;
//                             });
//                           },
//                     icon: Icon(Icons.fast_forward_rounded)),
//                 SizedBox(),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void playingbtn() async {
//     if (file_path != widget.map_data["UrlAsset"]) {
//       await preparePlaying();
//       return;
//     }
//     print("state playing btn ${fsPayer.playerState} ");

//     switch (fsPayer.playerState) {
//       case PlayerState.isPlaying:
//         await fsPayer.pausePlayer();
//         setState(() {
//           recordButtonIcon = Icons.play_arrow_rounded;
//         });
//         break;
//       case PlayerState.isPaused:
//         await fsPayer.resumePlayer();
//         setState(() {
//           recordButtonIcon = Icons.pause_rounded;
//         });
//         break;

//       default:
//         await preparePlaying();
//     }

//     print("state playing btn 2 ${fsPayer.playerState} ");
//   }
// }
