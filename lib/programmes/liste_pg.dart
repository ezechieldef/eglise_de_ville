// import 'dart:html';
import 'dart:io';
import 'dart:ui';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/const_notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart';
import '../contantes.dart';
import 'package:intl/src/intl/date_format.dart';

// import 'package:flutter_native_timezone/flutter_native_timezone_web.dart';

class ListePG1 extends StatefulWidget {
  @override
  State<ListePG1> createState() => _ListePG1State();
}

class _ListePG1State extends State<ListePG1> with TickerProviderStateMixin {
  List<Map<String, dynamic>> list_program = [{}, {}, {}];
  bool isload = false;
  DateTime now = DateTime.now();
  List<PendingNotificationRequest>? pendingNotificationRequests;

  AnimationController? _controller;
  Animation<Offset>? _animation;

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  // AndroidInitializationSettings initializationSettingsAndroid =
  //     AndroidInitializationSettings('logo');
  // final IOSInitializationSettings initializationSettingsIOS =
  //     IOSInitializationSettings();
  // InitializationSettings? initializationSettings;
  // FlutterLocalNotificationsPlugin? fltnotif;
  // FlutterLocalNotificationsPlugin.initialize(initializationSettings,
  //     onSelectNotification: onSelectNotification);
  bool check_alarm(
      List<PendingNotificationRequest>? pending, Map<String, dynamic> map) {
    if (pending == null) {
      return false;
    }
    for (var i = 0; i < pending.length; i++) {
      if (pending[i].id.toString() == map["id"].toString()) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _animation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: const Offset(0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInCubic,
    ));

    try {
      fltnotif!.pendingNotificationRequests().then((value) {
        setState(() {
          pendingNotificationRequests = value;
        });
      });
    } catch (e) {}

    chargement();
  }

  // void shownotif_event(Map<String, dynamic> map) async {
  //   DateTime moment = DateTime.parse(map["Date"].toString());
  //   var android_detail = AndroidNotificationDetails("id", "Programme");
  //   var ios_detail = IOSNotificationDetails();
  //   var general_notif_detail =
  //       NotificationDetails(android: android_detail, iOS: ios_detail);
  //   if (Platform.isAndroid || Platform.isIOS) {
  //     //  fltnotif!.show(1, 'Rappel - Culte', 'Le culte commence bientôt',
  //     //     general_notif_detail);

  //     // final scheduledDate = TZDateTime.from(moment, await getLocation());
  //     print("momoment $moment");
  //     fltnotif!
  //         .schedule(2, "Rappel BG", 'Body BG', moment, general_notif_detail);
  //     // fltnotif!.zonedSchedule(
  //     //     2, 'Rappel BG', 'Body BG', scheduledDate, general_notif_detail,
  //     //     uiLocalNotificationDateInterpretation:
  //     //         UILocalNotificationDateInterpretation.absoluteTime,
  //     //     androidAllowWhileIdle: true);
  //   } else {
  //     try {
  //       await fltnotif!.show(1, 'Rappel - Culte', 'Le culte commence bientôt',
  //           general_notif_detail);

  //       // final scheduledDate = TZDateTime.from(moment, await getLocation());
  //     } catch (e) {
  //       print("pas supporter mais j'ai insisté");
  //       print(e);
  //     }
  //   }
  // }

  void chargement() async {
    if (mounted)
      setState(() {
        isload = true;
        list_program = [];
      });
    var t = await select_data(
        "CALL programme_jour('" + now.toString().split(" ").first + "') ");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      if (mounted)
        setState(() {
          list_program = select_distinct(t);
        });
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage("Avertissement", t[0]["error"].toString(), context);
    }
    if (mounted)
      setState(() {
        isload = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          TableCalendar(
            focusedDay: now,
            firstDay: get_semaine(now)["D"],
            lastDay: get_semaine(now)["F"],
            calendarFormat: CalendarFormat.week,
            headerVisible: false,
            locale: 'fr_FR',
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: (old, neww) {
              if (now.year != neww.year ||
                  now.month != neww.month ||
                  now.day != neww.day) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Consulter l'onglet calendrier afin de voir les programmes du " +
                            neww.toString().split(" ").first)));
              }
            },
            calendarStyle: CalendarStyle(
                todayTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Material"),
                defaultTextStyle:
                    TextStyle(color: Colors.black, fontFamily: "Material"),
                weekendTextStyle:
                    TextStyle(color: Colors.black, fontFamily: "Material"),
                todayDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    shape: BoxShape.rectangle,
                    color: Colors.red[700]!),
                weekendDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    shape: BoxShape.rectangle,
                    color: Colors.grey[100]!),
                defaultDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    shape: BoxShape.rectangle,
                    color: Colors.grey[100]!)),
          ),
          // Center(
          //   child: Text(
          //     "Programmes de la semaine".toUpperCase(),
          //     textAlign: TextAlign.center,
          //     style: TextStyle(
          //         color: Colors.grey[800],
          //         // letterSpacing: 1.0,
          //         fontWeight: FontWeight.w600),
          //   ),
          // ),
          SizedBox(
            height: 15,
          ),
          Flexible(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: isload
                  ? Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : list_program.length == 0
                      ? Column(
                          children: [
                            SizedBox(
                              height: 25,
                            ),
                            Text("Pas de programme disponible "),
                            SizedBox(
                              height: 15,
                            ),
                            Flexible(
                                child: LottieBuilder.asset(
                                    "assets/lotties/lf20_n2m0isqh.json")),
                          ],
                        )
                      : ListView(
                          children: [
                            for (var j = 0; j < list_program.length; j++)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: SlideTransition(
                                  position: _animation!,
                                  child: IntrinsicHeight(
                                    child: Row(
                                      // verticalDirection: j.isEven
                                      //     ? VerticalDirection.down
                                      //     : VerticalDirection.up,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Center(
                                          child: Text(
                                              formatTimeOfDay(TimeOfDay.fromDateTime(
                                                      DateTime.parse("1990-01-01 " +
                                                          list_program[j][
                                                                  "Heure_Debut"]
                                                              .toString()))) +
                                                  "\n-\n" +
                                                  formatTimeOfDay(TimeOfDay
                                                      .fromDateTime(DateTime.parse(
                                                          "1990-01-01 " +
                                                              list_program[j]
                                                                      ["Heure_Fin"]
                                                                  .toString()))),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.grey[500]!,
                                                // fontFamily: "Material",
                                                fontSize: 13,
                                                // fontWeight: FontWeight.w600,
                                                // fontSize: 17,
                                              )),
                                        ),
                                        VerticalDivider(
                                          width: 25,
                                          color: Colors.grey[300],
                                          thickness: 0.5,
                                        ),
                                        Flexible(
                                            child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: (get_color())["c"],
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: ListTile(
                                            onTap: () {
                                              dialog_rapel_event(
                                                  list_program[j], context);
                                            },
                                            // textColor: Colors.black,
                                            // leading: Container(
                                            //   width: 4,
                                            //   decoration: BoxDecoration(
                                            //       color: Colors.grey,
                                            //       borderRadius:
                                            //           BorderRadius.circular(5)),
                                            //   margin: EdgeInsets.symmetric(
                                            //       vertical: 7),
                                            // ),
                                            // leading: Icon(Icons.puce),
                                            title: Text(
                                              list_program[j]["Titre"]
                                                  .toString(),
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            trailing: Icon(
                                              check_alarm(
                                                      pendingNotificationRequests,
                                                      list_program[j])
                                                  ? CupertinoIcons.bell_fill
                                                  : CupertinoIcons.bell,
                                              color: Colors.red[200],
                                            ),
                                          ),
                                        ))
                                      ],
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
            ),
          )
        ],
      ),
    );
  }

  Map<String, dynamic> get_semaine(DateTime d) {
    DateTime lun = d;
    DateTime dimanche = d;

    while (lun.weekday != DateTime.monday) {
      lun = lun.subtract(Duration(days: 1));
    }

    while (dimanche.weekday != DateTime.sunday) {
      dimanche = dimanche.add(Duration(days: 1));
    }
    return {"D": lun, "F": dimanche};
  }

  Map<String, dynamic> get_color_old(int pos, int index) {
    List<Map<String, dynamic>> color_list = [
      {"c": Colors.blue[300], "f": Colors.blue[600], "t": true},
      {"c": Colors.red[300], "f": Colors.red[600], "t": true},
      {
        "c": Color.fromRGBO(69, 229, 69, 1),
        "f": Color.fromARGB(255, 47, 185, 47),
        "t": true
      },
    ];
    var fff = {"c": Colors.grey[200]!, "t": false};
    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    Map<String, dynamic> m = {
      "c": Colors.grey[200]!,
      "t": false,
      "f": Colors.grey[300]
    };
    if (pos == 0) {
      m = color_list[index];
    }

    return m;
  }

  int p_color = 0;
  Map<String, dynamic> get_color() {
    List<Map<String, dynamic>> color_list = [
      {"c": Colors.orange[100]!.withOpacity(0.5), "t": Colors.black},
      {"c": Colors.green[100]!.withOpacity(0.5), "t": Colors.black},
      {"c": Colors.grey[100], "t": Colors.black},
      // {"c": Color(0xffFFEFD8), "t": Colors.black},
      // {"c": Color(0xffE3F2E4), "t": Colors.black},
      // {"c": Color(0xffF5F5F5), "t": Colors.black},
    ];
    if (p_color == color_list.length) {
      p_color = 0;
    }
    // while (p_color > color_list.length - 1) {
    //   p_color -= color_list.length;
    // }

    return color_list[p_color++];
  }
}
