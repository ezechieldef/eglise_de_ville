import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';

import 'contantes.dart';
import 'package:intl/src/intl/date_format.dart';

AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('logo');
final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings();
InitializationSettings? initializationSettings;

FlutterLocalNotificationsPlugin? fltnotif;
bool peut_notifier = false;
void shownotif_event(Map<String, dynamic> map) async {
  DateTime moment = DateTime.parse(map["Date"].toString());
  var android_detail =
      AndroidNotificationDetails(DateTime.now().toString(), "EDV");
  var ios_detail = IOSNotificationDetails();
  var general_notif_detail =
      NotificationDetails(android: android_detail, iOS: ios_detail);
  if (Platform.isAndroid || Platform.isIOS) {
    //  fltnotif!.show(1, 'Rappel - Culte', 'Le culte commence bientôt',
    //     general_notif_detail);

    print("momoment $moment");
    fltnotif!.show(map["id"], 'EGLISE DE VILLE',
        'Vous serez notifier quand l\'heure sonnera', general_notif_detail);
    fltnotif!.schedule(map["id"], "EGLISE DE VILLE",
        'Rappel !!! L\'évement commence bientôt', moment, general_notif_detail);
  } else {
    try {
      await fltnotif!.show(1, 'Rappel - Culte', 'L\'évènement commence bientôt',
          general_notif_detail);

      // final scheduledDate = TZDateTime.from(moment, await getLocation());
    } catch (e) {
      print("pas supporter mais j'ai insisté");
      print(e);
    }
  }
  showSimpleNotification(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[700]!,
                    offset: Offset(0, 0),
                    blurRadius: 13)
              ]),
          child: Row(
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Succès ",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Rappel programmé avec succès, vous serez notifier quand l'heure sonnera . Demeurez béni(e) !",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              LottieBuilder.asset(
                "assets/lotties/lf20_atippmse.json",
                repeat: false,
                height: 50,
              )
            ],
          )),
    ),
    elevation: 0,
    background: Colors.transparent,
    slideDismiss: true,
    duration: Duration(seconds: 7),
    // trailing: LottieBuilder.network(
    //           "https://assets4.lottiefiles.com/packages/lf20_jbrw3hcz.json",
    //           height: 50,
    //         )
  );
}

bool peut_programmer(DateTime d, Duration dur) {
  return (DateTime.now().isBefore(d.subtract(dur)));
}

void dialog_rapel_event(Map<String, dynamic> map, BuildContext context) async {
  DateTime heure_debut = DateTime.parse(
      map["Date"].toString().split(" ").first +
          " " +
          map["Heure_Debut"].toString());
  DateTime heure_fin = DateTime.parse(map["Date"].toString().split(" ").first +
      " " +
      map["Heure_Fin"].toString());
  DateTime now = DateTime.now();
  String message = "";

  if (now.isBefore(heure_fin) && now.isAfter(heure_debut)) {
    message =
        "Cet évènement a déjà commencé.\nDans la mesure du possible ,vous devriez vite vous y rendre.  Demeurez béni(e) ! ";
  } else if (now.isBefore(heure_debut) &&
      heure_debut.difference(now) < Duration(hours: 1)) {
    message =
        "L'évènement commence dans moins d'une heure.\nDans la mesure du possible, vous devriez vite vous y rendre. Demeurez béni(e) !";
  } else if (now.isAfter(heure_fin) && heure_debut.difference(now).isNegative) {
    message = "Cet évènement a déjà été cloturé .\nDemeurez béni(e) ! ";
  }
  print(" tyty debut $heure_debut :: now $now :: diff " +
      heure_debut.difference(now).toString());

  showCupertinoModalPopup(
      context: context,
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      builder: (context) => CupertinoAlertDialog(
            title: Text(
              "Programmer un rappel",
            ),
            content: Column(children: [
              SizedBox(
                height: 15,
              ),
              Text(
                  "Pour l'évènement : " +
                      map["Titre"].toString() +
                      "\nDu " +
                      DateFormat.yMMMMEEEEd('fr')
                          .format(DateTime.parse(map['Date'].toString())),
                  textAlign: TextAlign.center),
              Text(
                  formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.parse(
                          "1990-01-01 " + map["Heure_Debut"].toString()))) +
                      " - " +
                      formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.parse(
                          "1990-01-01 " + map["Heure_Fin"].toString()))),
                  textAlign: TextAlign.center),
              SizedBox(
                height: 15,
              ),
              message.isEmpty
                  ? SizedBox()
                  : Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7)),
                      child: Text(
                        message,
                        style: TextStyle(
                            fontFamily: 'SourceSansPro',
                            fontWeight: FontWeight.w400,
                            color: Colors.red[900],
                            fontSize: 16),
                      )),
              !peut_programmer(heure_debut, Duration(hours: 1))
                  ? SizedBox()
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7)),
                      child: CupertinoDialogAction(
                        child: Text("1 Heure avant "),
                        // isDestructiveAction: true,
                        onPressed: () {
                          if (!peut_programmer(heure_debut, Duration(hours: 2)))
                            showSimpleNotification(
                                Text(
                                    "L'évènement commence dans moins d'une heure \nDans la mesure du possible ,vous devriez vite vous y apprêter. Demeurez béni(e) !"),
                                subtitle: Text("Désolé"));
                          var tp = dupliquer([map])[0];
                          tp.update(
                              "Date",
                              (value) =>
                                  heure_debut.subtract(Duration(hours: 1)));
                          shownotif_event(tp);
                          Navigator.pop(context);
                        },
                      )),
              SizedBox(
                height: 10,
              ),
              !peut_programmer(heure_debut, Duration(hours: 2))
                  ? SizedBox()
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7)),
                      child: CupertinoDialogAction(
                          // isDestructiveAction: true,
                          child: Text("2 Heures avant "),
                          onPressed: () {
                            if (!peut_programmer(
                                heure_debut, Duration(hours: 2)))
                              showSimpleNotification(
                                  Text(
                                      "L'évènement commence dans moins de 2 heures \nDans la mesure du possible ,vous devriez vite vous y apprêter. Demeurez béni(e) !"),
                                  subtitle: Text("Désolé"));
                            var tp = dupliquer([map])[0];
                            tp.update(
                                "Date",
                                (value) =>
                                    heure_debut.subtract(Duration(hours: 2)));
                            shownotif_event(tp);
                            Navigator.pop(context);
                          })),
              SizedBox(
                height: 10,
              ),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(7)),
                  child: CupertinoDialogAction(
                    child: Text(
                      "Annuler",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
            ]),
          ));
}

void afficher_notification(
    int id, String titre, String contenu, String payload, String chaine) async {
  var android_detail = AndroidNotificationDetails(chaine, chaine);
  var ios_detail = IOSNotificationDetails();
  var general_notif_detail =
      NotificationDetails(android: android_detail, iOS: ios_detail);
  contenu = contenu.replaceAll("\n", ".");
  // if (contenu.length > 100) {
  //   contenu = contenu.substring(0, 100) + " ...";
  // }
  try {
    // sleep(Duration(seconds: 1));
    // print(
    //     "notification INFO id=$id chaine=$chaine titre=$titre payload=$payload");
    fltnotif!.show(id, titre, contenu, general_notif_detail, payload: payload);
    // fltnotif!.show(id, titre, "simple", general_notif_detail);
  } catch (e) {
    print(e);
  }
}
