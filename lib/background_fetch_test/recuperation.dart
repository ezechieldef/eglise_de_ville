import 'dart:convert';
import 'dart:io';

import 'package:eglise_de_ville/background_fetch_test/test.dart';
import 'package:eglise_de_ville/const_notification.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_operation.dart';
import '../sqlite_folder/principal.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;

List<String> table_list_rec = ["Enseignement", "Lyrics", "Programme"];
List<Map<String, dynamic>> notif_list = [
  // {"Enseignement": []},
  // {"Lyrics": []},
  // {"Programme": []}
];
Future<void> recuperer_bg() async {
  bool notif = true;

  await signal_exec();
  var t = await select_local_sqlite("SELECT * from execution", []);
  if (t.length == 1) {
    notif = false;
  }

  var json = {};
  table_list_rec.forEach((element) {
    json[element] = 'SELECT * from $element';
  });
  var rep = await multiple_query(jsonEncode(json));

  if (rep != null && rep.isNotEmpty && !rep.containsKey("error")) {
    notif_list.clear();
    // print("rept " + rep.keys.toString());

    for (var table in rep.keys) {
      dynamic list = rep[table];
      var rt = await select_local_sqlite("SELECT * from $table WHERE 1", []);
      var old_id_list = rt.map((e) => int.parse(e["id"].toString())).toList();
      var new_id_list =
          list[0].map((e) => int.parse(e["id"].toString())).toList();
      // print(
      //     "zanga test $table old = $old_id_list new = $new_id_list , to add ");
      new_id_list.removeWhere((element) => old_id_list.contains(element));
      // var new_id_list = list[0].map((e) => int.parse(e["id"].toString())).toList();
      // print("zanga tset $table to add = $new_id_list ");

      List<Map<String, dynamic>> l = [];

      list[0].forEach((element) {
        Map<String, dynamic> m = {};
        element.forEach((key, value) {
          m[key] = value;
        });

        if (new_id_list.contains(int.parse(m["id"].toString()))) {
          l.add(m);
          // print("zanga add $table " + m["id"].toString());
        } else {
          // print("zanga existe déjà  $table " + m["id"].toString());
        }
      });

      notif_list.add({"table": table, "data": l});

      // notifier_nouveau();

      await inserer_local_list(table, l);
      // print("new linsert notif_list $notif_list");
    }
  }
  notif_list.forEach((element) {
    print("yigi notif_list " +
        element["table"] +
        " " +
        element['data'].length.toString());
  });

  if (notif) {
    notifier_nouveau();
  }
}

void notifier_nouveau() {
  var temp = dupliquer(notif_list);
  temp.forEach((element) {
    switch (element["table"].toString().toLowerCase()) {
      case "programme":
        List<dynamic> n_list = element["data"];
        n_list.forEach((map) {
          DateTime? dt = DateTime.tryParse(map["Date"].toString());
          if (map['Repetition'].toString() == "-" &&
              dt != null &&
              DateTime.now().isBefore(dt)) {
            afficher_notification(
                (int.tryParse(map["id"].toString()) ?? 0) + 1000,
                "Evenement : " + map["Titre"].toString(),
                "Prévu pour le " + map["Date"].toString().split(" ").first,
                {
                  "PAYLOAD": element["table"].toString().toUpperCase(),
                  "PAYLOAD_DATA_ID": map["id"] ?? 0
                }.toString(),
                element["table"].toString());
          }
        });
        break;

      default:
        List<dynamic> n_list = element["data"];
        n_list.forEach((map) {
          var myJSON = jsonDecode(map["Contenu"].toString());
          fq.QuillController _control_doc = fq.QuillController(
              document: fq.Document.fromJson(myJSON),
              selection: TextSelection.collapsed(offset: 0));

          afficher_notification(
              (int.parse(map["id"].toString())) +
                  ((element["code"].toString().toLowerCase() == "enseignement")
                      ? 2000
                      : 3000),
              map["Titre"].toString(),
              _control_doc.document.toPlainText().toString(),
              {
                "PAYLOAD": element["code"].toString().toUpperCase(),
                "PAYLOAD_DATA_ID": map["id"] ?? 0
              }.toString(),
              element["table"].toString());
        });
        break;
    }

    // List<dynamic> n_list=element["data"];
    //     n_list.forEach((map) {
    //       afficher_notification(int.tryParse(map["id"].toString())??0, map[titre_champ].toString(), map[content_champ].toString(), {"PAYLOAD": element["code"].toString().toUpperCase(), "PAYLOAD_DATA_ID": map["id"] ?? 0 }.toString())
    //   });
  });
}
