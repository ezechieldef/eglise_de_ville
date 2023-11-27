import 'dart:async';
import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/background_fetch_test/recuperation.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:background_fetch/background_fetch.dart';

// [Android-only] This "Headless Task" is run when the Android app
// is terminated with enableHeadless: true
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  recuperer_bg();
  BackgroundFetch.finish(taskId);
}

Future<void> initialiser_arriere_plan() async {
  // Configure BackgroundFetch.
  int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          startOnBoot: true,
          forceAlarmManager: true,
          requiredNetworkType: NetworkType.ANY), (String taskId) async {
    print("[BackgroundFetch] Event received $taskId");
    await recuperer_bg();
    print("[BackgroundFetch] Event received finishing $taskId");

    BackgroundFetch.finish(taskId);
  }, (String taskId) async {
    print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
    BackgroundFetch.finish(taskId);
  });
  print('[BackgroundFetch] configure success: $status');
}

Future<void> signal_exec() async {
  try {
    await inserer_local("execution", {"Date": DateTime.now().toString()});
  } catch (e) {
    await raw_query_local(
        "CREATE TABLE execution (id INTEGER, Date TEXT, PRIMARY KEY(id AUTOINCREMENT) );");
    await inserer_local("execution", {"Date": DateTime.now().toString()});
  }
}

// void main() {
//   // Enable integration testing with the Flutter Driver extension.
//   // See https://flutter.io/testing/ for more info.
//   runApp(new MyApp());

//   // Register to receive BackgroundFetch events after app is terminated.
//   // Requires {stopOnTerminate: false, enableHeadless: true}
//   BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => new _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool _enabled = true;
//   int _status = 0;
//   List<DateTime> _events = [];

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     // Configure BackgroundFetch.
//     int status = await BackgroundFetch.configure(
//         BackgroundFetchConfig(
//             minimumFetchInterval: 15,
//             stopOnTerminate: false,
//             enableHeadless: true,
//             requiresBatteryNotLow: false,
//             requiresCharging: false,
//             requiresStorageNotLow: false,
//             requiresDeviceIdle: false,
//             requiredNetworkType: NetworkType.ANY), (String taskId) async {
//       // <-- Event handler
//       // This is the fetch-event callback.
//       print("[BackgroundFetch] Event received $taskId");
//       recuperer_bg();
//       // setState(() {
//       //   _events.insert(0, new DateTime.now());
//       // });
//       // IMPORTANT:  You must signal completion of your task or the OS can punish your app
//       // for taking too long in the background.
//       BackgroundFetch.finish(taskId);
//     }, (String taskId) async {
//       // <-- Task timeout handler.
//       // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
//       print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
//       BackgroundFetch.finish(taskId);
//     });
//     print('[BackgroundFetch] configure success: $status');
//     // setState(() {
//     //   _status = status;
//     // });

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;
//   }

//   void _onClickEnable(enabled) {
//     setState(() {
//       _enabled = enabled;
//     });
//     if (enabled) {
//       BackgroundFetch.start().then((int status) {
//         print('[BackgroundFetch] start success: $status');
//       }).catchError((e) {
//         print('[BackgroundFetch] start FAILURE: $e');
//       });
//     } else {
//       BackgroundFetch.stop().then((int status) {
//         print('[BackgroundFetch] stop success: $status');
//       });
//     }
//   }

//   void _onClickStatus() async {
//     int status = await BackgroundFetch.status;
//     print('[BackgroundFetch] status: $status');
//     setState(() {
//       _status = status;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//       home: new Scaffold(
//         appBar: new AppBar(
//             title: const Text('BackgroundFetch Example',
//                 style: TextStyle(color: Colors.black)),
//             backgroundColor: Colors.amberAccent,
//             brightness: Brightness.light,
//             actions: <Widget>[
//               Switch(value: _enabled, onChanged: _onClickEnable),
//             ]),
//         body: Container(
//           color: Colors.black,
//           child: new ListView.builder(
//               itemCount: _events.length,
//               itemBuilder: (BuildContext context, int index) {
//                 DateTime timestamp = _events[index];
//                 return InputDecorator(
//                     decoration: InputDecoration(
//                         contentPadding:
//                             EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
//                         labelStyle: TextStyle(
//                             color: Colors.amberAccent, fontSize: 20.0),
//                         labelText: "[background fetch event]"),
//                     child: new Text(timestamp.toString(),
//                         style: TextStyle(color: Colors.white, fontSize: 16.0)));
//               }),
//         ),
//         bottomNavigationBar: BottomAppBar(
//             child: Row(children: <Widget>[
//           RaisedButton(onPressed: _onClickStatus, child: Text('Status')),
//           Container(
//               child: Text("$_status"), margin: EdgeInsets.only(left: 20.0))
//         ])),
//       ),
//     );
//   }
// }
