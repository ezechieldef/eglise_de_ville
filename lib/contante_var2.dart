import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'sqlite_folder/principal.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
GoogleSignInAccount? googleUser;

ThemeData _dtd_light = ThemeData(brightness: Brightness.light);
ThemeData _dtd_dark = ThemeData(brightness: Brightness.dark);
TextTheme text_l = _dtd_light.textTheme;
TextTheme text_d = _dtd_dark.textTheme;
ThemeData themeData =
    WidgetsBinding.instance!.window.platformBrightness == Brightness.dark
        ? themeDatadark
        : themeDatalight;

ThemeData themeDatadark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'SourceSansPro',
    primarySwatch: Colors.red,
    appBarTheme: _dtd_dark.appBarTheme.copyWith(
        color: Color(0xff000000),
        titleTextStyle: (_dtd_dark.appBarTheme.titleTextStyle ?? TextStyle())
            .copyWith(color: Colors.white),
        elevation: 0,
        shadowColor: Colors.white24,
        iconTheme: (_dtd_dark.appBarTheme.iconTheme ?? IconThemeData())
            .copyWith(color: Colors.white.withOpacity(.7))),
    iconTheme:
        _dtd_dark.iconTheme.copyWith(color: Colors.white.withOpacity(.7)),
    scaffoldBackgroundColor: Colors.black,
    textTheme: _dtd_dark.textTheme.copyWith(
      headline1: (text_l.headline1 ?? TextStyle())
          .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      headline2: (text_l.headline2 ?? TextStyle())
          .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      headline3: (text_l.headline3 ?? TextStyle())
          .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      headline4: (text_l.headline4 ?? TextStyle())
          .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      headline5: (text_l.headline5 ?? TextStyle())
          .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      headline6: (text_l.headline6 ?? TextStyle())
          .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      subtitle1:
          (text_l.subtitle1 ?? TextStyle()).copyWith(color: Colors.white),
      subtitle2:
          (text_l.subtitle2 ?? TextStyle()).copyWith(color: Colors.white),
      bodyText1:
          (text_l.bodyText1 ?? TextStyle()).copyWith(color: Colors.white),
      bodyText2:
          (text_l.bodyText2 ?? TextStyle()).copyWith(color: Colors.white),
      caption: (text_l.headline1 ?? TextStyle()).copyWith(color: Colors.white),
      button: (text_l.headline1 ?? TextStyle()).copyWith(color: Colors.white),
      overline: (text_l.headline1 ?? TextStyle()).copyWith(color: Colors.white),
    ));
ThemeData themeDatalight = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'SourceSansPro',
    primarySwatch: Colors.red,
    appBarTheme: _dtd_light.appBarTheme.copyWith(
        color: Color(0xfffafafa),
        titleTextStyle: (_dtd_light.appBarTheme.titleTextStyle ?? TextStyle())
            .copyWith(color: Colors.black),
        elevation: 0,
        iconTheme: (_dtd_light.appBarTheme.iconTheme ?? IconThemeData())
            .copyWith(color: Colors.black.withOpacity(.7))),
    iconTheme:
        _dtd_light.iconTheme.copyWith(color: Colors.black.withOpacity(.7)),
    scaffoldBackgroundColor: Color(0xfffafafa),
    textTheme: _dtd_light.textTheme.copyWith(
      headline1: (text_l.headline1 ?? TextStyle())
          .copyWith(color: Colors.black, fontWeight: FontWeight.w600),
      headline2: (text_l.headline2 ?? TextStyle())
          .copyWith(color: Colors.black, fontWeight: FontWeight.w600),
      headline3: (text_l.headline3 ?? TextStyle())
          .copyWith(color: Colors.black, fontWeight: FontWeight.w600),
      headline4: (text_l.headline4 ?? TextStyle())
          .copyWith(color: Colors.black, fontWeight: FontWeight.w600),
      headline5: (text_l.headline5 ?? TextStyle())
          .copyWith(color: Colors.black, fontWeight: FontWeight.w600),
      headline6: (text_l.headline6 ?? TextStyle())
          .copyWith(color: Colors.black, fontWeight: FontWeight.w600),
      subtitle1:
          (text_l.subtitle1 ?? TextStyle()).copyWith(color: Colors.black),
      subtitle2:
          (text_l.subtitle2 ?? TextStyle()).copyWith(color: Colors.black),
      bodyText1:
          (text_l.bodyText1 ?? TextStyle()).copyWith(color: Colors.black),
      bodyText2:
          (text_l.bodyText2 ?? TextStyle()).copyWith(color: Colors.black),
      caption: (text_l.headline1 ?? TextStyle()).copyWith(color: Colors.black),
      button: (text_l.headline1 ?? TextStyle()).copyWith(color: Colors.black),
      overline: (text_l.headline1 ?? TextStyle()).copyWith(color: Colors.black),
    ));

bool isDark() {
  return (themeData.brightness == Brightness.dark);
}

Color textColor() {
  return themeData.textTheme.bodyText1!.color!;
}

Future<bool> checkLogin(BuildContext context) async {
  //googleSignIn.signOut();
  showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              content: Container(
                decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(10)),
                // height: 100,
                padding: EdgeInsets.symmetric(vertical: 20),
                width:
                    double.infinity, //?? MediaQuery.of(context).size.width * .4
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Authentification",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      CupertinoActivityIndicator(
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ));

  if (!await isSignedIn()) {
    return await handleSignIn(context);
  }

  Navigator.of(context).pop();

  return true;
}

googleLogout() {
  try {
    googleUser = null;
    googleSignIn.signOut();
  } catch (e) {}
}

Future<bool> isSignedIn() async {
  return await googleSignIn.isSignedIn();
}

Future<bool> handleSignIn(BuildContext context) async {
  try {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    String? idToken = googleAuth.idToken;
    String? accessToken = googleAuth.accessToken;
    Navigator.of(context).pop();
    var t = {
      "nom": googleUser.displayName!,
      "email": googleUser.email,
      "id": googleUser.email,
      "photo": googleUser.photoUrl ?? ""
    };
    var r = await insert_data(t, "google_users");
    if (r["statut"] != 0) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Une erreur s'est produite, vérifier votre conexion internet svp !")));
    }
    await inserer_local("users", t);
    await verif_conn();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Connexion réussi")));
    // Utilisez les jetons pour authentifier l'utilisateur avec votre backend
    return true;
  } catch (error) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Une erreur s'est produite ")));
    print("ca va pas $error");
    return false;
  }
  Navigator.of(context).pop();

  return false;
}

showNotif(BuildContext context, String text, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Padding(
        padding: const EdgeInsets.all(15),
        child: Text(text),
      )));
}

void pushr2(BuildContext context, dynamic p) {
  Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(builder: (context) => (p)), (route) => false);
}
