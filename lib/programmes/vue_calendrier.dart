import 'dart:convert';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/const_notification.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';

class VueCalendrier extends StatefulWidget {
  const VueCalendrier({Key? key}) : super(key: key);

  @override
  State<VueCalendrier> createState() => _VueCalendrierState();
}

class _VueCalendrierState extends State<VueCalendrier>
    with TickerProviderStateMixin {
  // DateTime focuday = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<dynamic>> list_event = {DateTime.now(): []};
  int get_nombre_jour_du_mois(DateTime d) {
    DateTime temp = d;
    int max = d.day;
    while (temp.month == d.month) {
      temp = temp.add(Duration(days: 1));
      max++;
    }
    return max - 1;
  }

  String camelCase(String h) {
    var v = h.split(" ");
    var res;
    for (var i = 0; i < v.length; i++) {
      v[i] = v[i][0].toUpperCase() + v[i].substring(1);
    }
    return v.join(" ");
  }

  bool event_loading = false;
  AnimationController? _controller;
  Animation<Offset>? _animation;

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _animation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: const Offset(0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInCubic,
    ));

    super.initState();

    load_events();
  }

  remplacement(Map<DateTime, List<dynamic>> mp) {
    mp.forEach((key, list) {
      list.forEach((element) {
        element.update("Date", (value) => key);
      });
    });
  }

  void load_events() async {
    if (mounted)
      setState(() {
        event_loading = true;
      });
    List<DateTime> ldt = [
      for (var i = 1; i <= get_nombre_jour_du_mois(DateTime.now()); i++)
        DateTime.utc(DateTime.now().year, DateTime.now().month, i)
    ];
    Map<String, String> m = {};
    ldt.forEach((element) {
      m[element.toString().split(" ").first] =
          "CALL programme_jour('" + element.toString().split(" ").first + "')";
    });
    var rep = await multiple_query(jsonEncode(m));
    if (rep != null && rep.isNotEmpty && !rep.containsKey("error")) {
      Map<DateTime, List<dynamic>> mo = {};
      rep.forEach((key, value) {
        DateTime? tp = DateTime.parse(key + ' 00:00:00');
        mo[DateTime.utc(tp.year, tp.month, tp.day)] =
            select_distinct_for_dynamic(List.castFrom(value).first);
        tp = null;
      });
      remplacement(mo);
      if (mounted)
        setState(() {
          list_event = mo;
          print(list_event);
        });
    } else if (rep != null && rep.isNotEmpty && rep.containsKey("error")) {
      showMessage("Avertissement", rep["error"].toString(), context);
    }
    if (mounted)
      setState(() {
        event_loading = false;
      });
    print("lancé2");
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        // backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          elevation: 1,
          // backgroundColor: Colors.white,
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
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: event_loading
              ? Center(
                  child: CupertinoActivityIndicator(),
                )
              : ListView(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    TableCalendar(
                      headerStyle: HeaderStyle(
                        leftChevronVisible: false,
                        rightChevronVisible: false,
                        titleTextFormatter: (date, locale) =>
                            camelCase(DateFormat.yMMMM(locale).format(date)),
                        titleTextStyle: TextStyle(
                            fontFamily: "Material",
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600),
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      rangeSelectionMode: RangeSelectionMode.disabled,

                      // pageJumpingEnabled: false,
                      selectedDayPredicate: (day) {
                        // Use `selectedDayPredicate` to determine which day is currently selected.
                        // If this returns true, then `day` will be marked as selected.

                        // Using `isSameDay` is recommended to disregard
                        // the time-part of compared DateTime objects.
                        return isSameDay(_selectedDay, day);
                      },
                      eventLoader: (DateTime d) {
                        // var r =
                        // if (list_event[d] != null) {
                        //   list_event[d]!.forEach((element) {
                        //     r.add(element.toString());
                        //   });
                        // } else {
                        //   print("events  null $d");
                        // }
                        // print("events $d " + r.length.toString());

                        return list_event[d] ?? [];
                      },

                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          // Call `setState()` when updating the selected day
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          if (_controller!.isCompleted) {
                            _controller!.reset();
                            _controller!.forward();
                          }
                        }
                      },
                      daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(color: Colors.red[200]),
                          weekendStyle: TextStyle(color: Colors.red[200])),
                      calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          isTodayHighlighted: true,
                          markersAutoAligned: false,
                          markerDecoration: BoxDecoration(
                              color: Colors.grey[300], shape: BoxShape.circle),
                          todayDecoration: BoxDecoration(
                            color: Colors.grey[100],
                            border:
                                Border.all(color: Colors.red[200]!, width: 1),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 5)
                            ],
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          todayTextStyle: TextStyle(
                              color: Colors.black, fontFamily: "Material"),
                          // markerDecoration:
                          // BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          selectedDecoration: BoxDecoration(
                              color: Colors.red[700]!,
                              // boxShadow: [
                              //   BoxShadow(color: Colors.teal[100]!, blurRadius: 5)
                              // ],
                              borderRadius: BorderRadius.circular(5),
                              shape: BoxShape.rectangle),
                          defaultDecoration: BoxDecoration(
                              color: Colors.grey[100]!.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5)),
                          weekendDecoration: BoxDecoration(
                            color: Colors.grey[100]!.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          weekendTextStyle: TextStyle(
                              color: Colors.red[200], fontFamily: "Material"),
                          selectedTextStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: "Material"),
                          defaultTextStyle: TextStyle(fontFamily: "Material")),
                      availableCalendarFormats: {CalendarFormat.month: "Mois"},
                      firstDay: DateTime.utc(
                          DateTime.now().year, DateTime.now().month, 01),
                      lastDay: DateTime.utc(
                          DateTime.now().year,
                          DateTime.now().month,
                          get_nombre_jour_du_mois(DateTime.now())),
                      locale: 'fr_FR',
                      focusedDay: _focusedDay,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Divider(
                      indent: 5,
                      endIndent: 5,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    list_event[_selectedDay] != null &&
                            list_event[_selectedDay]!.isEmpty
                        ? Column(
                            children: [
                              SizedBox(
                                height: 25,
                              ),
                              Text("Pas de programme disponible "),
                              SizedBox(
                                height: 15,
                              ),
                              LottieBuilder.asset(
                                  "assets/lotties/lf20_n2m0isqh.json"),
                            ],
                          )
                        : SizedBox(),
                    for (var i = 0;
                        i < (list_event[_selectedDay]?.length ?? 0);
                        i++)
                      InkWell(
                        onTap: () {
                          dialog_rapel_event(
                              list_event[_selectedDay]![i], context);
                        },
                        child: SlideTransition(
                          position: _animation!,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: (get_color(i))['c'],
                            ),
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              list_event[_selectedDay]![i]
                                                      ["Titre"]
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                // color: (get_color(i))['t']
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              child: Text(
                                                  list_event[_selectedDay]![i]
                                                          ["Description"]
                                                      .toString(),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      // fontStyle: FontStyle.italic,
                                                      // fontFamily: "Material",
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: themeData.textTheme
                                                          .bodyText1!.color!
                                                          .withOpacity(0.8))),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Icon(CupertinoIcons.clock_fill,
                                                    color: themeData.textTheme
                                                        .bodyText1!.color!
                                                        .withOpacity(0.8),
                                                    size: 20),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                      formatTimeOfDay(TimeOfDay.fromDateTime(
                                                              DateTime.parse("1990-01-01 " +
                                                                  list_event[_selectedDay]![i]
                                                                          [
                                                                          "Heure_Debut"]
                                                                      .toString()))) +
                                                          " - " +
                                                          formatTimeOfDay(TimeOfDay.fromDateTime(
                                                              DateTime.parse(
                                                                  "1990-01-01 " +
                                                                      list_event[_selectedDay]![i]["Heure_Fin"]
                                                                          .toString()))),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: "Material",
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      )),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    VerticalDivider(
                                        color: themeData
                                            .textTheme.bodyText1!.color!
                                            .withOpacity(0.2)),
                                    RotatedBox(
                                      quarterTurns: 3,
                                      child: Text(
                                        list_event[_selectedDay]![i]
                                                ["Personne_Cible"]
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          // fontFamily: "Material",
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
        ),
      ),
    );
  }

  Map<String, dynamic> get_color(int index) {
    List<Map<String, dynamic>> color_list = [
      {"c": Colors.red[100]!.withOpacity(0.5), "t": Colors.black},
      {"c": Colors.blue[100]!.withOpacity(0.5), "t": Colors.black},
      {"c": Colors.orange[100]!.withOpacity(0.5), "t": Colors.black},
      {"c": Colors.grey[100], "t": Colors.black},
    ];

    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    return color_list[index];
  }
}
