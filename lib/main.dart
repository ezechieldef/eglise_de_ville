import 'dart:async';
import 'dart:io';
import 'package:eglise_de_ville/background_fetch_test/recuperation.dart';
import 'package:eglise_de_ville/background_fetch_test/test.dart';
import 'package:eglise_de_ville/const_notification.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/lyrics/lyrics_showing2.dart';
import 'package:eglise_de_ville/splash/splash_screen.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

//
import 'package:overlay_support/overlay_support.dart';

import 'drawer.dart';
import 'firebase_options.dart';
import 'menu_screen.dart';
// import 'package:localization/localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:background_fetch/background_fetch.dart';

Future<void> checkForUpdate() async {
  if (Platform.isAndroid) {
    var inf = await InAppUpdate.checkForUpdate();
    if (inf.updateAvailability == UpdateAvailability.updateAvailable) {
      await InAppUpdate.startFlexibleUpdate();
    }
    print("check $inf");
  }

  // InAppUpdate.checkForUpdate().then((info) {
  //   print("dd $info");
  // }).catchError((e) {});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    googleSignIn.forceCodeForRefreshToken;

    googleSignIn.onCurrentUserChanged.listen((event) {
      googleUser = event;
    });
  }

  HttpOverrides.global = new MyHttpOverrides();
  initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  fltnotif = FlutterLocalNotificationsPlugin();
  peut_notifier = await fltnotif!.initialize(initializationSettings!) ?? false;

  WidgetsBinding.instance!.window.onPlatformBrightnessChanged = () {
    // final brightness = WidgetsBinding.instance!.window.platformBrightness;
    themeData =
        WidgetsBinding.instance!.window.platformBrightness == Brightness.dark
            ? themeDatadark
            : themeDatalight;
  };

  try {
    await verif_conn();
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    initialiser_arriere_plan();

    Timer.periodic(Duration(minutes: 1), (timer) {
      try {
        recuperer_bg();
      } catch (e) {
        print("timerrecuperer bg echec $e");
      }
    });
  } catch (e) {
    print(e);
  }
  runApp(MyAppBase());
  try {
    await verif_conn();
    if (Platform.isAndroid || Platform.isIOS) {
      if (connected_user.isEmpty) {
        if (await googleSignIn.isSignedIn()) {
          GoogleSignInAccount? googleUsertemp =
              await googleSignIn.signInSilently();
          GoogleSignInAuthentication googleAuth =
              await googleUsertemp!.authentication;
          googleUser = googleUsertemp;
          await inserer_local("users", {
            "nom": googleUser!.displayName!,
            "email": googleUser!.email,
            "id": googleUser!.email,
            "photo": googleUser!.photoUrl ?? ""
          });
          await verif_conn();
          print("connected $connected_user");
        }
      }
    }
  } catch (e) {}

  if (Platform.isAndroid || Platform.isIOS) {
    checkForUpdate();
  }
}

class MyAppBase extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate
          // LocalJsonLocalization.delegate,
        ],
        supportedLocales: [const Locale('en'), const Locale('FR', "fr")],
        title: 'Eglise de Ville',
        debugShowCheckedModeBanner: false,
        darkTheme: themeDatadark,
        theme: themeData,
        home: Scaffold(
            resizeToAvoidBottomInset: true,
            body:
                //InitDrawer(home_page: "dimes")
                SplashScreenEDV()),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
