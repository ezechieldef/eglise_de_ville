import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

import 'bible_reading.dart';

class SurlignerPage extends StatefulWidget {
  const SurlignerPage({Key? key}) : super(key: key);

  @override
  State<SurlignerPage> createState() => _SurlignerPageState();
}

class _SurlignerPageState extends State<SurlignerPage> {
  bool isload = false;
  List<Map<String, dynamic>> list_couleur = [];
  List<Map<String, dynamic>> list_livres_data = [];
  List<Map<String, dynamic>> list_verset = [];
  List<Map<String, dynamic>> list_edition = [];
  Map<String, Color> surligneCoulors = {
    "yellow": Colors.yellow.withOpacity(.8),
    "cyan": Colors.cyan.withOpacity(.8),
    "pink": Colors.pinkAccent.withOpacity(.8),
    "green": CupertinoColors.activeGreen.withOpacity(.8),
    "orange": CupertinoColors.activeOrange.withOpacity(.8),
    "purple": CupertinoColors.systemPurple.withOpacity(.8)
  };
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialiser();
  }

  void initialiser() async {
    setState(() {
      isload = true;
    });
    // var db = await executer_transact_sql();
    var t = await select_local_sqlite_bible(
        "SELECT * from Bibles ORDER BY ID ASC", []);
    setState(() {
      list_edition = dupliquer(t);
    });
    await charger_livres();
    await charger_favoris();

    print(list_couleur);
    setState(() {
      isload = false;
    });
  }

  Future<void> charger_livres({String liblivre = ""}) async {
    setState(() {
      isload = true;
    });
    if (list_edition.isNotEmpty) {
      var t_name = list_edition.first["Table_Name"].toString();
      var g = await select_local_sqlite_bible("SELECT * from $t_name", []);
      setState(() {
        list_verset = dupliquer(g);
      });
      var t = await select_local_sqlite_bible(
          "SELECT D.Livre, L.Libele, count(DISTINCT D.Chapitre) Chap from $t_name D , Livres L WHERE L.id=D.Livre AND L.Libele LIKE '%'||?||'%' GROUP BY D.Livre ORDER BY D.Livre ASC ",
          [liblivre]);
      setState(() {
        list_livres_data = dupliquer(t);
      });
    }

    setState(() {
      isload = false;
    });
  }

  String get_contenu_bible(Map<String, dynamic> map) {
    String ar = "";
    list_verset.forEach((element) {
      if (element["Livre"] == map['Livre'] &&
          element['Chapitre'] == map['Chapitre'] &&
          element['Verset'] == map['Verset']) {
        ar = element['Contenu'].toString();
      }
    });
    return ar;
  }

  Map<String, dynamic>? get_map(String champ, dynamic valeur) {
    Map<String, dynamic>? aret;
    list_livres_data.forEach((element) {
      if (element.containsKey(champ) &&
          element[champ].toString() == valeur.toString()) {
        aret = element;
      }
    });
    return aret;
  }

  Future<void> charger_favoris() async {
    setState(() {
      isload = true;
    });
    var t = await select_local_sqlite_bible(
        "SELECT * from Customisation WHERE Cle = ? OR Cle=?",
        ["Couleur", "Souligner"]);
    setState(() {
      list_couleur = dupliquer(t).reversed.toList();
    });
    setState(() {
      isload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Text(
          "Mes Surlignements".toUpperCase(),
          textAlign: TextAlign.start,
          style: TextStyle(
              color: textColor().withOpacity(.7), fontWeight: FontWeight.w600),
        ),
      ),
      SizedBox(
        height: 10,
      ),
      Flexible(
          child: isload
              ? Center(
                  child: CupertinoActivityIndicator(),
                )
              : list_couleur.isEmpty
                  ? Column(
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        Text("Aucun élément enregistré pour le moment"),
                        SizedBox(
                          height: 15,
                        ),
                        Flexible(
                          child: LottieBuilder.asset(
                              "assets/lotties/lf20_n2m0isqh.json"),
                        ),
                      ],
                    )
                  : ListView.separated(
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 0,
                          indent: 10,
                          endIndent: 10,
                        );
                      },
                      itemCount: list_couleur.length,
                      itemBuilder: ((context, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                routeTransition(ReadCharpenterBible({
                                  "Table": list_edition.first["Table_Name"]
                                      .toString(),
                                  "Version":
                                      list_edition.first["Version"].toString(),
                                  "LibLivre": get_map(
                                          'Livre',
                                          list_couleur[index]
                                              ['Livre'])!['Libele']
                                      .toString(),
                                  "Livre": get_map('Livre',
                                      list_couleur[index]['Livre'])!['Livre'],
                                  "Chapitre": list_couleur[index]['Chapitre'],
                                  "MaxChapitre": get_map('Livre',
                                      list_couleur[index]['Livre'])!["Chap"]
                                })));
                          },
                          title: Text(
                            get_map('Livre', list_couleur[index]['Livre'])![
                                        'Libele']
                                    .toString() +
                                " " +
                                list_couleur[index]['Chapitre'].toString() +
                                " : " +
                                list_couleur[index]['Verset'].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            get_contenu_bible(list_couleur[index]),
                            style: TextStyle(
                                color: textColor(),
                                backgroundColor: surligneCoulors[
                                        list_couleur[index]['Valeur']] ??
                                    Colors.transparent,
                                decoration:
                                    list_couleur[index]['Valeur'].toString ==
                                            "true"
                                        ? TextDecoration.underline
                                        : TextDecoration.none),
                          ),
                        );
                      })))
    ]);
  }
}
