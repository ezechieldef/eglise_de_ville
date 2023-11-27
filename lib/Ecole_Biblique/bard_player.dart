import 'package:eglise_de_ville/contante_var2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AudioPlayerWidget extends StatefulWidget {
  String audioUrl;

  AudioPlayerWidget({required this.audioUrl});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration();
  Duration _position = Duration();
  bool _isLoading = false;
  IconData playPauseIcon = FontAwesomeIcons.solidCirclePlay;
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  playPauseBtnClick() async {
    // switch (_audioPlayer.state) {
    //   case PlayerState.playing:
    //     setState(() {
    //       playPauseIcon = FontAwesomeIcons.solidCirclePlay;
    //     });
    //     _audioPlayer.pause();
    //     break;
    //   case PlayerState.paused:
    //     setState(() {
    //       playPauseIcon = FontAwesomeIcons.solidCirclePause;
    //     });
    //     _audioPlayer.resume();

    //     break;

    //   default:
    //     setState(() {
    //       _isLoading = true;
    //       _position = Duration.zero;
    //     });
    //     await _audioPlayer.play(UrlSource(widget.audioUrl));
    //     setState(() {
    //       playPauseIcon = FontAwesomeIcons.solidCirclePause;
    //       _isLoading = false;
    //     });
    // }
    switch (_audioPlayer.state) {
      case PlayerState.playing:
        _audioPlayer.pause();
        break;
      case PlayerState.paused:
        _audioPlayer.resume();

        break;

      default:
        setState(() {
          _isLoading = true;
          _position = Duration.zero;
        });
        await _audioPlayer.play(UrlSource(widget.audioUrl));
        setState(() {
          _isLoading = false;
        });
    }
  }

  void _initAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
    _audioPlayer.onSeekComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        // playPauseIcon = FontAwesomeIcons.solidCirclePause;
      });
      print("cash fin");
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      print("cash state changed $state");

      switch (state) {
        case PlayerState.playing:
          setState(() {
            playPauseIcon = FontAwesomeIcons.solidCirclePause;
          });

          break;
        case PlayerState.paused:
          setState(() {
            playPauseIcon = FontAwesomeIcons.solidCirclePlay;
          });
          break;
        case PlayerState.completed:
          setState(() {
            playPauseIcon = FontAwesomeIcons.solidCirclePlay;
          });
          break;
        case PlayerState.stopped:
          setState(() {
            playPauseIcon = FontAwesomeIcons.solidCirclePlay;
          });
          break;

        default:
          setState(() {
            playPauseIcon = FontAwesomeIcons.solidCirclePlay;
          });
      }
    });
    actualiserSource();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AudioPlayerWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    try {
      if (mounted) actualiserSource();
    } catch (e) {}
  }

  void actualiserSource() async {
    if (mounted) {
      setState(() {
        _duration = Duration.zero;
        _position = Duration.zero;
        _isLoading = true;
      });

      await _audioPlayer.play(UrlSource(widget.audioUrl));
      await _audioPlayer.pause();
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.only(bottom: 5, left: 10, right: 10),
        decoration: BoxDecoration(
            color: isDark() ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isDark()
                    ? Color.fromARGB(15, 255, 255, 255)
                    : Colors.grey[100]!),
            boxShadow: [
              BoxShadow(
                  color: isDark() ? Colors.black26 : Colors.grey[300]!,
                  offset: Offset(0, 4),
                  blurRadius: 4),
            ]),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 5),
          leading: _isLoading
              ? CupertinoActivityIndicator(
                  color: Colors.red,
                )
              : IconButton(
                  icon: Icon(
                    playPauseIcon,
                    size: 35,
                    color: isDark() ? Colors.red[300] : Colors.red,
                  ),
                  onPressed: playPauseBtnClick,
                ),
          subtitle: Opacity(
              opacity: .7,
              child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,

                    overlayShape: RoundSliderOverlayShape(
                        overlayRadius:
                            0), // Ajustez le rayon de l'overlay si nécessaire
                    thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius:
                            5), // Ajustez le rayon du pouce du Slider
                    valueIndicatorShape:
                        PaddleSliderValueIndicatorShape(), // Utilisez PaddleSliderValueIndicatorShape pour ajuster le padding
                  ),
                  child: Slider(
                    value: _position.inSeconds.toDouble(),
                    // divisions: _duration.inSeconds.toInt()  ,
                    onChanged: (value) {},
                    onChangeStart: (v) {
                      if (_isLoading) return;

                      if (_audioPlayer.state == PlayerState.playing) {
                        _audioPlayer.pause();
                      }
                    },

                    onChangeEnd: (value) async {
                      // print("cash changed");
                      if (_isLoading) return;

                      if (_audioPlayer.state == PlayerState.playing) {
                        await _audioPlayer.pause();
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                        await _audioPlayer.resume();
                      } else if (_audioPlayer.state == PlayerState.paused) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                        await _audioPlayer.resume();
                      } else {
                        setState(() {
                          _isLoading = true;
                        });
                        await _audioPlayer.play(UrlSource(widget.audioUrl));
                        setState(() {
                          _isLoading = false;
                        });
                        await _audioPlayer
                            .seek(Duration(seconds: value.toInt()));

                        // await _audioPlayer.resume();
                      }
                    },
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                  ))),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(_position).toString(),
                style: TextStyle(
                  fontFamily: "Circular",
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatDuration(_duration).toString(),
                style: TextStyle(
                  fontFamily: "Circular",
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
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
