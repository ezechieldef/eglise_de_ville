import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../contante_var2.dart';
import '../contantes.dart';
import '../sqlite_folder/principal.dart';
import 'bible_reading.dart';

class FavorisPage extends StatefulWidget {
  const FavorisPage({Key? key}) : super(key: key);

  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  bool isload = false;
  List<Map<String, dynamic>> list_favoris = [];
  List<Map<String, dynamic>> list_livres_data = [];
  List<Map<String, dynamic>> list_verset = [];
  List<Map<String, dynamic>> list_edition = [];

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
    if (mounted)
      setState(() {
        list_edition = dupliquer(t);
      });
    await charger_livres();
    await charger_favoris();

    if (mounted)
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
        "SELECT * from Customisation WHERE Cle = ?", ["Favoris"]);
    setState(() {
      list_favoris = dupliquer(t).reversed.toList();
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
          "Mes Favoris".toUpperCase(),
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
              : list_favoris.isEmpty
                  ? Column(
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        Text("Aucun favoris enregistré pour le moment"),
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
                      itemCount: list_favoris.length,
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
                                          list_favoris[index]
                                              ['Livre'])!['Libele']
                                      .toString(),
                                  "Livre": get_map('Livre',
                                      list_favoris[index]['Livre'])!['Livre'],
                                  "Chapitre": list_favoris[index]['Chapitre'],
                                  "MaxChapitre": get_map('Livre',
                                      list_favoris[index]['Livre'])!["Chap"]
                                })));
                          },
                          title: Text(
                            get_map('Livre', list_favoris[index]['Livre'])![
                                        'Libele']
                                    .toString() +
                                " " +
                                list_favoris[index]['Chapitre'].toString() +
                                " : " +
                                list_favoris[index]['Verset'].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              get_contenu_bible(list_favoris[index]) + "  ❤"),
                        );
                      })))
    ]);
  }
}
