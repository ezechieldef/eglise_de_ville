// import 'dart:convert';
// import 'dart:math';

// import 'package:eglise_de_ville/serveur_custom.dart';
// import 'package:http/http.dart' as http;

// Future<Map<String, dynamic>> insert_data_laravel(
//     Map<String, dynamic> data, String table) async {
//   try {
//     var rep = await http.post(
//       Uri.parse(serveur_moderne),
//       body: {
//         "operation": "INSERT_DUP",
//         "params": jsonEncode(data),
//         "table": table
//       },
//       headers: {
//         'Charset': 'utf-8',
//       },
//     );
//     print("reponse :: " + rep.body);
//     if (jsonDecode(rep.body) != null && jsonDecode(rep.body) == 0) {
//       return {"status": "OK", "response": jsonDecode(rep.body) ?? ""};
//     } else {
//       return {
//         "status": "PAS OK",
//         "message": "response " + jsonDecode(rep.body).toString()
//       };
//     }
//   } catch (e) {
//     print("connection échoué  $e");

//     if (e.runtimeType.toString() == "SocketException") {
//       return {
//         "status": "PAS OK",
//         "message":
//             "Connexion au server impossible, vérifier votre connexion internet svp !"
//       };
//     } else if (e.runtimeType.toString() == "TimeoutException") {
//       return {
//         "status": "PAS OK",
//         "message":
//             "Connexion au server impossible, vérifier votre connexion internet svp !"
//       };
//     } else {
//       return {"status": "PAS OK", "message": "Une erreur s'est produite"};
//     }
//   }
// }

// Future<Map<String, dynamic>> insert_data_get_id_laravel(
//     Map<String, dynamic> data, String table) async {
//   try {
//     print(serveur_moderne);

//     var rep = await http.post(
//       Uri.parse(serveur_moderne),
//       body: {
//         "operation": "INSERT_ID",
//         "params": jsonEncode(data),
//         "table": table
//       },
//       headers: {
//         'Charset': 'utf-8',
//       },
//     );
//     print("reponse :: " + rep.body);
//     if (jsonDecode(rep.body) != null && jsonDecode(rep.body) == 0) {
//       return {"status": "OK", "response": jsonDecode(rep.body) ?? ""};
//     } else if (int.tryParse(jsonDecode(rep.body).toString()) != null) {
//       return {"status": "OK", "ID": jsonDecode(rep.body)};
//     } else {
//       return {
//         "status": "PAS OK",
//         "message": "response " + jsonDecode(rep.body).toString()
//       };
//     }
//   } catch (e) {
//     print("connection échoué  $e");

//     if (e.runtimeType.toString() == "SocketException") {
//       return {
//         "status": "PAS OK",
//         "message":
//             "Connexion au server impossible, vérifier votre connexion internet svp !"
//       };
//     } else if (e.runtimeType.toString() == "TimeoutException") {
//       return {
//         "status": "PAS OK",
//         "message":
//             "Connexion au server impossible, vérifier votre connexion internet svp !"
//       };
//     } else {
//       return {"status": "PAS OK", "message": "Une erreur s'est produite $e"};
//     }
//   }
// }

// Future<List<Map<String, dynamic>>>? select_data_laravel(
//   String query,
// ) async {
//   try {
//     print("SELECT laravel  $serveur_moderne");
//     print("roles body ${{
//       "operation": "SELECT",
//       "params": "[]",
//       "query": query
//     }}");

//     var rep = await http.post(
//       Uri.parse(serveur_moderne),
//       body: {"operation": "SELECT", "params": "[]", "query": query},
//       headers: {
//         'Charset': 'utf-8',
//       },
//     );
//     print("response :: serveur = $serveur_moderne");
//     print(
//         "reponse :: " + rep.body + " ::length = " + rep.body.length.toString());
//     if (jsonDecode(rep.body) != null) {
//       List<Map<String, dynamic>> l = [];
//       jsonDecode(rep.body).forEach((element) {
//         Map<String, dynamic> m = {};
//         element.forEach((key, value) {
//           m[key] = value;
//         });
//         l.add(m);
//       });
//       return l;
//     }
//   } catch (e) {
//     print("connection échoué  $e");

//     if (e.runtimeType.toString() == "SocketException") {
//       return [
//         {
//           "error":
//               "Connexion au server impossible, vérifier votre connexion internet svp !"
//         }
//       ];
//     } else if (e.runtimeType.toString() == "TimeoutException") {
//       return [
//         {
//           "error":
//               "Connexion au server impossible, vérifier votre connexion internet svp !"
//         }
//       ];
//     } else {
//       return [
//         {"error": "Une erreur s'est produite $e"}
//       ];
//     }
//   }
//   return [
//     {"error": "Une erreur s'est produite"}
//   ];
// }

// Future<bool>? exec_mysql_query_laravel(
//   String query,
// ) async {
//   try {
//     var rep = await http.post(
//       Uri.parse(serveur_delete),
//       body: {"query": jsonEncode(query)},
//       headers: {
//         'Charset': 'utf-8',
//       },
//     );
//     print(
//         "reponse :: " + rep.body + " ::length = " + rep.body.length.toString());
//     if (jsonDecode(rep.body) != null && jsonDecode(rep.body) == 0) {
//       return true;
//     }
//   } catch (e) {}
//   return false;
// }

// Future<Map<String, dynamic>>? multiple_query_laravel(
//   String json,
// ) async {
//   try {
//     // print("json : $json");
//     var rep = await http.post(
//       Uri.parse(serveur_multiple),
//       body: {"json": json},
//       headers: {
//         'Charset': 'utf-8',
//       },
//     );
//     // print(
//     //     "reponse :: " + rep.body + " ::length = " + rep.body.length.toString());

//     if (jsonDecode(rep.body) != null) {
//       Map<String, dynamic> table_list = jsonDecode(rep.body);
//       return table_list;
//     }
//   } catch (e) {
//     print("connection échoué  $e");

//     if (e.runtimeType.toString() == "SocketException") {
//       return {
//         "error":
//             "Connexion au server impossible, vérifier votre connexion internet svp !"
//       };
//     } else if (e.runtimeType.toString() == "TimeoutException") {
//       return {
//         "error":
//             "Connexion au server impossible, vérifier votre connexion internet svp !"
//       };
//     } else {
//       return {"error": "Une erreur s'est produite $e"};
//     }
//   }
//   return {"error": "Une erreur s'est produite"};
// }

import 'package:flutter/material.dart';

import '../api_operation_laravel.dart';
import '../contantes.dart';
