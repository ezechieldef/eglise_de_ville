import 'package:eglise_de_ville/contante_var2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

import '../contantes.dart';
import '../sqlite_folder/principal.dart';
import 'bible_reading.dart';

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  bool isload = false;
  List<Map<String, dynamic>> list_notes = [];
  List<Map<String, dynamic>> list_livres_data = [];
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
    setState(() {
      list_edition = dupliquer(t);
    });
    await charger_livres();
    await charger_notes();
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

  Future<void> charger_notes() async {
    setState(() {
      isload = true;
    });
    var t = await select_local_sqlite_bible(
        "SELECT * from Customisation WHERE Cle = ?", ["Notes"]);
    setState(() {
      list_notes = dupliquer(t);
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
          "Mes Notes".toUpperCase(),
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
              : list_notes.isEmpty
                  ? Column(
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        Text("Aucun notes enregistré pour le moment  "),
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
                      itemCount: list_notes.length,
                      itemBuilder: ((context, index) {
                        return ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  routeTransition(ReadCharpenterBible({
                                    "Table": list_edition.first["Table_Name"]
                                        .toString(),
                                    "Version": list_edition.first["Version"]
                                        .toString(),
                                    "LibLivre": get_map(
                                            'Livre',
                                            list_notes[index]
                                                ['Livre'])!['Libele']
                                        .toString(),
                                    "Livre": get_map('Livre',
                                        list_notes[index]['Livre'])!['Livre'],
                                    "Chapitre": list_notes[index]['Chapitre'],
                                    "MaxChapitre": get_map('Livre',
                                        list_notes[index]['Livre'])!["Chap"]
                                  })));
                            },
                            title: Text(
                              get_map('Livre', list_notes[index]['Livre'])![
                                          'Libele']
                                      .toString() +
                                  " " +
                                  list_notes[index]['Chapitre'].toString() +
                                  " : " +
                                  list_notes[index]['Verset'].toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: SelectableText(
                                list_notes[index]['Valeur'].toString()));
                      })))
    ]);
  }
}
