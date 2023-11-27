import 'dart:async';
import 'dart:ui';

import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/user_login/connexion_form.dart';
import 'package:eglise_de_ville/user_login/inscription_forl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../contantes.dart';
import 'decoration_acc.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  List<Map<String, dynamic>> list_camions = [];

  bool isload = false;
  bool isconnect = false;

  bool passshow = true;
  int _current_menu = 0;
  Map<String, dynamic> map_saisi = {"Email": null, "Password": ""};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   charger(context);
    // });
    // charger();
  }

  void showmessage(String titre, String mess, {bool dismis = true}) {
    showDialog(
      barrierDismissible: dismis,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titre),
          content: Text(
            mess,
            textAlign: TextAlign.center,
          ),
          actions: [
            MaterialButton(
                color: Color(0xff00C600),
                textColor: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Text("OK"),
                ),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }

  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: themeData.scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          // backgroundColor: Color(0xfffafafa),
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {
                exitloading(context);
              },
              icon: Icon(
                CupertinoIcons.xmark_circle_fill,
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
                color: themeData.iconTheme.color!.withOpacity(.7),
              ),
            )
          ],
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
        body: Container(
            width: double.infinity,
            height: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: CupertinoSlidingSegmentedControl(
                        thumbColor: Colors.white,
                        backgroundColor:
                            themeData.brightness == Brightness.light
                                ? CupertinoColors.tertiarySystemFill
                                : Colors.grey.withOpacity(0.5),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 7),
                        groupValue: _current_menu,
                        onValueChanged: (v) {
                          setState(() {
                            _current_menu = int.parse(v.toString());
                          });
                          pageController.jumpToPage(_current_menu);
                          // pageController.animateToPage(_current_menu,
                          //     duration: Duration(seconds: 1),
                          //     curve: Curves.decelerate);
                        },
                        children: {
                          0: Text(
                            "Connexion",
                            style: TextStyle(
                                color: _current_menu == 0
                                    ? Colors.black
                                    : textColor(),
                                fontWeight: _current_menu == 0
                                    ? FontWeight.w600
                                    : FontWeight.w500),
                          ),
                          1: Text(
                            "Inscription",
                            style: TextStyle(
                                color: _current_menu == 1
                                    ? Colors.black
                                    : textColor(),
                                fontWeight: _current_menu == 1
                                    ? FontWeight.w600
                                    : FontWeight.w500),
                          )
                        }),
                  ),
                ),
                Flexible(
                  child: PageView(
                    controller: pageController,
                    children: [ConnexionForm(), InscriptionForm()],
                  ),
                ),

                // SizedBox(
                //   width: double.infinity,
                //   child: IntrinsicHeight(
                //       child: _current_menu == 0
                //           ? ConnexionForm()
                //           : InscriptionForm()),
                // ),
              ],
            )),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     // extendBody: false,
  //     // extendBodyBehindAppBar: true,
  //     // appBar: AppBar(
  //     //   backgroundColor: Colors.transparent,
  //     //   elevation: 0,
  //     // ),
  //     body: SafeArea(
  //       child: Container(
  //         width: double.infinity,
  //         height: double.infinity,
  //         decoration: BoxDecoration(color: Colors.white),
  //         child: Stack(
  //           children: [
  //             Container(
  //               width: double.infinity,
  //               transform: Matrix4.translationValues(
  //                   0, -(MediaQuery.of(context).size.height / 3), 0),
  //               child: DecoAnim(),
  //             ),
  //             isload
  //                 ? Center(
  //                     // padding: const EdgeInsets.s(8.0),
  //                     child: CircularProgressIndicator(),
  //                   )
  //                 : Align(
  //                     alignment: Alignment.bottomCenter,
  //                     child: SafeArea(
  //                       child: SingleChildScrollView(
  //                         child: Wrap(
  //                           children: [
  //                             // Container(
  //                             //   alignment: Alignment.center,
  //                             //   width: double.infinity,
  //                             //   child: Container(
  //                             //       padding: EdgeInsets.symmetric(
  //                             //           horizontal: 10, vertical: 7),
  //                             //       decoration: BoxDecoration(boxShadow: [
  //                             //         BoxShadow(
  //                             //           color: Colors.white.withOpacity(0.5),
  //                             //         ),
  //                             //         BoxShadow(
  //                             //           offset: Offset(5, 5),
  //                             //           color: Colors.white.withOpacity(0.5),
  //                             //         ),
  //                             //       ], borderRadius: BorderRadius.circular(15)),
  //                             //       child: Text(
  //                             //         "Eglise De Ville ",
  //                             //         // textAlign: TextAlign.center,
  //                             //         style: TextStyle(
  //                             //             color: Colors.red[600]!,
  //                             //             fontSize: 20,
  //                             //             fontFamily: "Awake"),
  //                             //       )),
  //                             // ),
  //                             // SizedBox(
  //                             //   height: 100,
  //                             // ),

  //                             SizedBox(
  //                               width: double.infinity,
  //                               child: Padding(
  //                                 padding: const EdgeInsets.symmetric(
  //                                     horizontal: 15),
  //                                 child: CupertinoSlidingSegmentedControl(
  //                                     padding: EdgeInsets.symmetric(
  //                                         vertical: 5, horizontal: 7),
  //                                     groupValue: _current_menu,
  //                                     onValueChanged: (v) {
  //                                       setState(() {
  //                                         _current_menu =
  //                                             int.parse(v.toString());
  //                                       });
  //                                     },
  //                                     children: {
  //                                       0: Text(
  //                                         "Connexion",
  //                                         style: TextStyle(
  //                                             fontWeight: _current_menu == 0
  //                                                 ? FontWeight.w600
  //                                                 : FontWeight.w500),
  //                                       ),
  //                                       1: Text(
  //                                         "Inscription",
  //                                         style: TextStyle(
  //                                             fontWeight: _current_menu == 1
  //                                                 ? FontWeight.w600
  //                                                 : FontWeight.w500),
  //                                       )
  //                                     }),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                               width: double.infinity,
  //                               child: IntrinsicHeight(
  //                                   child: _current_menu == 0
  //                                       ? ConnexionForm()
  //                                       : InscriptionForm()),
  //                             ),

  //                             SizedBox(
  //                               height: 50,
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget get_rounded_back(Widget child) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(100),
      ),
      child: child,
    );
  }
}
