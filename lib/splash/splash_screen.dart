import 'dart:async';

import 'package:flutter/material.dart';

import '../drawer.dart';
import 'decoration_acc.dart';

class SplashScreenEDV extends StatefulWidget {
  const SplashScreenEDV({Key? key}) : super(key: key);

  @override
  State<SplashScreenEDV> createState() => _SplashScreenEDVState();
}

class _SplashScreenEDVState extends State<SplashScreenEDV>
    with TickerProviderStateMixin {
  bool debut = true;
  AnimationController? _controller;
  Animation<double>? _animation;
  double get_position() {
    if (debut) {
      debut = false;
      return -40;
    } else {
      return 40;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.periodic(Duration(milliseconds: 3000), (timer) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => InitDrawer()));
      timer.cancel();
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        backgroundColor:

            // Color(0xffAE121C),
            Color(0xff282828),
        // extendBody: false,
        // extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        // ),
        body: SafeArea(
            child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(color: Colors.transparent),
                child: Stack(children: [
                  // Container(
                  //   width: double.infinity,
                  //   transform: Matrix4.translationValues(
                  //       0, -(MediaQuery.of(context).size.height / 3), 0),
                  //   child: DecoAnim(),
                  // ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      // right: 0,
                      // left: 0,
                      // bottom: 20,
                      // width: 15,
                      // height: 15,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )),
                  Positioned(
                    // alignment: Alignment.center,
                    bottom: MediaQuery.of(context).size.height/4,
                    right: 0,
                    left: 0,
                    top: 0,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: false
                          ? FadeTransition(
                              opacity: _animation!,
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      color: Color(0xffAE121C),
                                      transform:
                                          Matrix4.translationValues(-12, 0, 0),
                                    ),
                                    RichText(
                                      textAlign: TextAlign.start,
                                      text: TextSpan(
                                          text: 'EGLISE ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Montserrat",
                                              fontSize: 20,
                                              height: 0.9,

                                              // color: Colors.black,
                                              // fontSize: 14,
                                              fontWeight: FontWeight.w300),
                                          children: [
                                            TextSpan(
                                              text: 'DE ',
                                              style: TextStyle(
                                                color: Color(0xffF49FA7),
                                                // color: Colors.black,

                                                // fontSize: 14,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'VILLE',
                                              style: TextStyle(
                                                  color: Color(0xffF30717),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            // TextSpan(
                                            //   text: '\nCITY CHURCH',
                                            //   style: TextStyle(
                                            //       color: Colors.white,
                                            //       fontWeight: FontWeight.w500),
                                            // )
                                          ]),
                                    ),
                                    // Text(
                                    //   "CITY CHURCH",
                                    //   style: TextStyle(
                                    //       fontFamily: 'Montserrat',
                                    //       fontWeight: FontWeight.w500,
                                    //       fontSize: 20,
                                    //       color: Colors.white),
                                    // ),
                                    IntrinsicWidth(
                                      child: Row(
                                        children: [
                                          Text(
                                            "CITY CHURCH",
                                            style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                          Container(
                                            width: 12,
                                            height: 12,
                                            color: Color(0xffF37B83),
                                            transform:
                                                Matrix4.translationValues(
                                                    0, 14, 0),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Image.asset("assets/image/logo.png")
                                  ],
                                ),
                              ),
                            )
                          : FadeTransition(
                              opacity: _animation!,
                              child: Image.asset(
                                "assets/image/logo.png",
                                width: double.infinity,
                              ),
                            ),
                    ),
                    // duration: Duration(seconds: 2)
                  )
                ]))));
  }
}
