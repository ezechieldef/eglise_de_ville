import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';

String vision_str =
    "\t\t\tL’Eglise de Ville (City Church) est un des rassemblements du corps de Christ établi par Dieu pour être la lumière des nations et pour porter le salut jusqu’aux extrémités de la terre par la prédication de la croix qui est une puissance de Dieu pour le salut de quiconque croit. Nous sommes donc engagés dans l’implantation des églises et des centres de formation chrétiens dans toutes les nations de la terre en vue de rassembler les sauvés pour le retour de notre Seigneur Jésus-Christ.\n\n\t\t\t\r L'église est la ville, elle est l'épouse.\nApocalypse 21: 9-10. Puis un des sept anges qui tenaient les sept coupes remplies des sept derniers fléaux vint, et il m'adressa la parole, en disant: Viens, je te montrerai l'épouse, la femme de l'agneau. Et il me transporta en esprit sur une grande et haute montagne. Et il me montra la ville sainte, Jérusalem, qui descendait du ciel d'auprès de Dieu.\nNous avons choisi de ne pas aller au-delà des écritures selon: 1 Corinthiens 4: 6. C'est à cause de vous, frères, que j'ai fait de ces choses une application à ma personne et à celle d'Apollos, afin que vous appreniez en nos personnes à ne pas aller au delà de ce qui est écrit, et que nul de vous ne conçoive de l'orgueil en faveur de l'un contre l'autre.\nC'est pour cela nous n'avons pas donné de nom à l'assemblée de Christ qui est sa femme.Dans les écritures nous remarquons également que l'église locale est identifiée par rapport à la ville dans laquelle elle se trouvait car Christ viendra chercher une ville.Ainsi nous ajoutons simplement le nom de la ville dans laquelle nous sommes présents au groupe de mot Eglise de ville. Un exemple : église de ville de cotonou (cotonou city church)";
BoxShadow boxdec_std =
    BoxShadow(offset: Offset(4, 4), blurRadius: 5, color: Colors.grey[300]!);
Color egv_col = Color(0xffa7052d);
bool admin = true;
String db_host = "mysql.eglisedeville.com"; //'sql241.main-hosting.eu';
String db_user = "charbellia"; //'u477274760_first_camp2';
String db_pass = 'SGNP?7M5Z1sF';
String db_name = "eglisedeville"; //'u477274760_first_camp2';
String serveur =
    "https://beraca-transport.net/EGLISEDEVILLE/"; //"https://eglisedeville.com/adminerrr/";
String serveur_moderne = "$serveur/insert_moderne.php";
String serveur_delete = "$serveur/insert_with_query.php";
String serveur_multiple = "$serveur/recuperation.php";
String server_up_img = serveur + "upload_image_gallery.php";
String server_up_img_carousel = serveur + "upload_image_gallery_carousel.php";
String internet_off_str =
    "L'accès internet est indisponible actuellement. Il se peut que ces données ne soient plus d'actualitées";
String username_domain = "deffed";
String passwd_domain = "40P@ssMy182000";
int admin_id = 0;
var bytes = "${base64.encode(utf8.encode('$username_domain:$passwd_domain'))}";
var headers = <String, String>{
  HttpHeaders.authorizationHeader: "Basic $bytes",
  "Accept": "application/json",
};
double scaleFactor = 1.0;
double baseScaleFactor = 1.0;
Map<String, dynamic> connected_user = {};
Future<bool> verif_conn() async {
  var t = await select_local_sqlite(
      "SELECT * from users ORDER BY id DESC LIMIT 1", []);

  if (t.isNotEmpty) {
    connected_user = t.first;
    print("tentative connxion ok");
    return true;
  } else {
    print("tentative connxion echec");

    return false;
  }
}

Map<String, dynamic> purger_int_map(Map<String, dynamic> data) {
  Map<String, dynamic> t = {};
  data.forEach((key, value) {
    if (int.tryParse(key.toString()) == null) {
      t[key] = value;
    }
  });
  return t;
}

List<Map<String, dynamic>> purger_list_int_map(
    List<Map<String, dynamic>> data) {
  List<Map<String, dynamic>> l = [];
  data.forEach((element) {
    l.add(purger_int_map(element));
  });
  return l;
}

List<Map<String, dynamic>> convert_dynamic_list_to_list_of_map(
    List<dynamic> data) {
  List<Map<String, dynamic>> l = [];
  data.forEach((element) {
    Map<String, dynamic> j = {};
    element.forEach((key, value) {
      j[key] = value;
    });
    l.add(j);
  });
  return l;
}

List<Map<String, dynamic>> dupliquer(List<Map<String, dynamic>> list) {
  List<Map<String, dynamic>> n_l = [];
  list.forEach((element) {
    Map<String, dynamic> ml = {};
    element.forEach((key, value) {
      ml[key] = value;
    });
    n_l.add(ml);
  });
  return n_l;
}

List<Map<String, dynamic>> select_distinct(List<Map<String, dynamic>> list) {
  List<Map<String, dynamic>> n_l = [];
  List<String> list_str = [];
  list.forEach((element) {
    if (!list_str.contains(element.toString())) {
      list_str.add(element.toString());
      Map<String, dynamic> ml = {};
      element.forEach((key, value) {
        ml[key] = value;
      });
      n_l.add(ml);
    }
  });

  return n_l;
}

List<dynamic> select_distinct_for_dynamic(List<dynamic> list) {
  List<dynamic> n_l = [];
  List<String> list_str = [];
  list.forEach((element) {
    if (!list_str.contains(element.toString())) {
      list_str.add(element.toString());
      n_l.add(element);
    }
  });

  return n_l;
}

// Future<Map<String, dynamic>> connexion() async {
//   print("connexion demare");
//   var settings = new ConnectionSettings(
//       host: db_host, port: 3306, user: db_user, password: db_pass, db: db_name);
//   var conn;

//   try {
//     conn = await MySqlConnection.connect(settings);
//   } catch (e) {
//     print("connection échoué");
//     print(e.toString() + " " + e.runtimeType.toString());
//     MySqlException exp;

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
//   print("connexion réussi");

//   return {"status": "OK", "data": conn};
// }

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

void showMessageJolie(
    String titre, String mess, Color color, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => Theme(
            data: themeData,
            child: AlertDialog(
              title: Text(titre,
                  style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontFamily: "Circular",
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600)),
              content: Text(mess),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: color,
                    ))
              ],
            ),
          ));
}

String formatTimeOfDay(TimeOfDay tod) {
  final now = new DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
  final format = DateFormat.jm("fr"); //"6:00 AM"
  return format.format(dt);
}

String camelCase(String h) {
  var v = h.split(" ");
  var res;
  for (var i = 0; i < v.length; i++) {
    v[i] = v[i][0].toUpperCase() + v[i].substring(1);
  }
  return v.join(" ");
}

String formatstf(dynamic data) {
  if (data.runtimeType.toString() == "DateTime") {
    return DateFormat.MMMEd("fr").format(data);
    // return data.toString().split(" ")[0].split("-").reversed.join("-");
  } else if (data.runtimeType.toString() == "TimeRange") {
    return formatTimeOfDay(data.startTime) +
        " - " +
        formatTimeOfDay(data.endTime);
  } else if (data.runtimeType.toString() == "TimeOfDay") {
    return formatTimeOfDay(data);
  } else if (data == null) {
    return "";
  }

  return data.toString();
}

Widget get_cached_image(String img_url,
    {double? cheight = double.infinity,
    double? cwiddth = double.infinity,
    BoxFit cfit = BoxFit.cover}) {
  return CachedNetworkImage(
    imageUrl: img_url,
    width: cwiddth,
    height: cheight,

    filterQuality: FilterQuality.high,
    fit: cfit,
    // imageBuilder: (context, imageProvider) => PhotoView(
    //   imageProvider: imageProvider,
    // ),
    progressIndicatorBuilder:
        (context, chaine, DownloadProgress loadingProgress) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          color: Colors.grey[200],
          child: Shimmer.fromColors(
            baseColor: Colors.red,
            highlightColor: Colors.white.withOpacity(0.5),
            child: Center(
              child: loadingProgress == null
                  ? CircularProgressIndicator()
                  : CircularProgressIndicator(value: loadingProgress.progress),
            ),
          ),
        ),
      );
    },
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}

void showloading(BuildContext context) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Theme(
            data: themeData,
            child: AlertDialog(
              content: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Center(
                    child: CircularProgressIndicator(),
                  )),
            ),
          ));
}

void exitloading(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

Route routeTransition(dynamic page2) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page2,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

String formatagee(String somme) {
  var buffer = new StringBuffer();
  somme = somme.replaceAll(" ", "");
  int i = somme.length;
  while (i > 0) {
    buffer.write(somme[somme.length - i]);
    i--;
    if (i % 3 == 0) {
      buffer.write(" ");
    }
  }
  return buffer.toString();
}
