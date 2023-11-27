import 'dart:convert';
import 'dart:math';

import 'package:eglise_de_ville/serveur_custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'contante_var2.dart';

Future<Map<String, dynamic>> insert_data(
    Map<String, dynamic> data, String table) async {
  try {
    var rep = await http.post(
      Uri.parse(serveur_moderne),
      body: {
        "operation": "INSERT_DUP",
        "params": jsonEncode(data),
        "table": table
      },
      headers: {
        'Charset': 'utf-8',
      },
    );
    print("reponse :: " + rep.body);
    if (jsonDecode(rep.body) != null && jsonDecode(rep.body) == 0) {
      return {"status": "OK", "response": jsonDecode(rep.body) ?? ""};
    } else {
      return {
        "status": "PAS OK",
        "message": "response " + jsonDecode(rep.body).toString()
      };
    }
  } catch (e) {
    print("connection échoué  $e");

    if (e.runtimeType.toString() == "SocketException") {
      return {
        "status": "PAS OK",
        "message":
            "Connexion au server impossible, vérifier votre connexion internet svp !"
      };
    } else if (e.runtimeType.toString() == "TimeoutException") {
      return {
        "status": "PAS OK",
        "message":
            "Connexion au server impossible, vérifier votre connexion internet svp !"
      };
    } else {
      return {"status": "PAS OK", "message": "Une erreur s'est produite"};
    }
  }
}

Future<Map<String, dynamic>> insert_data_get_id(
    Map<String, dynamic> data, String table) async {
  try {
    print(serveur_moderne);

    var rep = await http.post(
      Uri.parse(serveur_moderne),
      body: {
        "operation": "INSERT_ID",
        "params": jsonEncode(data),
        "table": table
      },
      headers: {
        'Charset': 'utf-8',
      },
    );
    print("reponse :: " + rep.body);
    if (jsonDecode(rep.body) != null && jsonDecode(rep.body) == 0) {
      return {"status": "OK", "response": jsonDecode(rep.body) ?? ""};
    } else if (int.tryParse(jsonDecode(rep.body).toString()) != null) {
      return {"status": "OK", "ID": jsonDecode(rep.body)};
    } else {
      return {
        "status": "PAS OK",
        "message": "response " + jsonDecode(rep.body).toString()
      };
    }
  } catch (e) {
    print("connection échoué  $e");

    if (e.runtimeType.toString() == "SocketException") {
      return {
        "status": "PAS OK",
        "message":
            "Connexion au server impossible, vérifier votre connexion internet svp !"
      };
    } else if (e.runtimeType.toString() == "TimeoutException") {
      return {
        "status": "PAS OK",
        "message":
            "Connexion au server impossible, vérifier votre connexion internet svp !"
      };
    } else {
      return {"status": "PAS OK", "message": "Une erreur s'est produite $e"};
    }
  }
}

Future<List<Map<String, dynamic>>>? select_data(
  String query,
) async {
  try {
    print("SELECT  $serveur_moderne");

    var rep = await http.post(
      Uri.parse(serveur_moderne),
      body: {"operation": "SELECT", "params": "[]", "query": query},
      headers: {
        'Charset': 'utf-8',
      },
    );
    print(
        "reponse :: " + rep.body + " ::length = " + rep.body.length.toString());
    if (jsonDecode(rep.body) != null) {
      List<Map<String, dynamic>> l = [];
      jsonDecode(rep.body).forEach((element) {
        Map<String, dynamic> m = {};
        element.forEach((key, value) {
          m[key] = value;
        });
        l.add(m);
      });
      return l;
    }
  } catch (e) {
    print("connection échoué  $e");

    if (e.runtimeType.toString() == "SocketException") {
      return [
        {
          "error":
              "Connexion au server impossible, vérifier votre connexion internet svp !"
        }
      ];
    } else if (e.runtimeType.toString() == "TimeoutException") {
      return [
        {
          "error":
              "Connexion au server impossible, vérifier votre connexion internet svp !"
        }
      ];
    } else {
      return [
        {"error": "Une erreur s'est produite $e"}
      ];
    }
  }
  return [
    {"error": "Une erreur s'est produite"}
  ];
}

Future<bool>? exec_mysql_query(
  String query,
) async {
  try {
    var rep = await http.post(
      Uri.parse(serveur_delete),
      body: {"query": jsonEncode(query)},
      headers: {
        'Charset': 'utf-8',
      },
    );
    print(
        "reponse :: " + rep.body + " ::length = " + rep.body.length.toString());
    if (jsonDecode(rep.body) != null && jsonDecode(rep.body) == 0) {
      return true;
    }
  } catch (e) {}
  return false;
}

Future<Map<String, dynamic>>? multiple_query(
  String json,
) async {
  try {
    // print("json : $json");
    var rep = await http.post(
      Uri.parse(serveur_multiple),
      body: {"json": json},
      headers: {
        'Charset': 'utf-8',
      },
    );
    // print(
    //     "reponse :: " + rep.body + " ::length = " + rep.body.length.toString());

    if (jsonDecode(rep.body) != null) {
      Map<String, dynamic> table_list = jsonDecode(rep.body);
      return table_list;
    }
  } catch (e) {
    print("connection échoué  $e");

    if (e.runtimeType.toString() == "SocketException") {
      return {
        "error":
            "Connexion au server impossible, vérifier votre connexion internet svp !"
      };
    } else if (e.runtimeType.toString() == "TimeoutException") {
      return {
        "error":
            "Connexion au server impossible, vérifier votre connexion internet svp !"
      };
    } else {
      return {"error": "Une erreur s'est produite $e"};
    }
  }
  return {"error": "Une erreur s'est produite"};
}

List<Map<String, dynamic>>? AudioLangues = null;

Future<List<Map<String, dynamic>>> getLangues(BuildContext context) async {
  if (AudioLangues != null) {
    return AudioLangues!;
  }
  List<Map<String, dynamic>> langues = [];
  var t = await select_data('SELECT * from Langue ');

  if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
    langues = t;
    AudioLangues = langues;
  } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
    showMessage(
        "Avertissement", "Erreur lors du chargement des langues", context);
  }

  return langues;
}

void showMessage(String titre, String mess, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => Theme(
            data: themeData,
            child: AlertDialog(
              title: Text(titre),
              content: Text(mess),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(CupertinoIcons.xmark_circle_fill))
              ],
            ),
          ));
}
