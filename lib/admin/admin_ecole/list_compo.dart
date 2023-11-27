import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:eglise_de_ville/admin/admin_ecole/add_chapitre.dart';
import 'package:eglise_de_ville/admin/admin_ecole/quiz.dart';
import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:html_editor/html_editor.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../contantes.dart';
import 'package:intl/intl.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

class AdminListeComposition extends StatefulWidget {
  Map<String, dynamic> map_data = {};
  AdminListeComposition(Map<String, dynamic> k) {
    map_data = k;
  }

  @override
  State<AdminListeComposition> createState() =>
      _AdminListeCompositionState(this.map_data);
}

class _AdminListeCompositionState extends State<AdminListeComposition> {
  bool isload = false;
  Map<String, dynamic> map_data;

  _AdminListeCompositionState(this.map_data) {}

  List<Map<String, dynamic>> list_compo = [];
String search_str="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargement();
  }

  void chargement() async {
    setState(() {
      isload = true;
      list_compo = [];
    });
  var t = await select_data(
        "SELECT Distinct U.id, U.nom, (SELECT count(*) from Chapitres where id_cours='${map_data["id"]}') nbre_chapitre from Chapitres Ch, Quiz Q, composer_quiz CQ, users U "
        "WHERE Ch.id=Q.id_chapitre AND Q.id=CQ.quiz_id AND CQ.user_id=U.id "
        " AND CQ.Details!='' AND Ch.id_cours='${map_data["id"]}' ORDER BY U.nom ASC");
    print(t);
    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_compo = t;
      });
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage("Erreur", t[0]["error"].toString(), context);
    }
    setState(() {
      isload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDatalight,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
              centerTitle: true,
              elevation: 0.5,
              backgroundColor: Colors.white,
              leading: IconButton(
                  onPressed: () {
                    exitloading(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: CupertinoColors.activeGreen,
                  )),
              title: Text(
                "Composition : "+ map_data["Titre"].toString(),
                style: TextStyle(color: Colors.black),
              )),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  "Liste des Compositions".toUpperCase(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.grey[800],
                      // fontSize: 13,
                      // letterSpacing: 1.0,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: CupertinoSearchTextField(
                  style: TextStyle(fontFamily: "Material", fontSize: 14),
                  // backgroundColor: Colors.white,
                  placeholder: "Rechercher ...",
                  onChanged: (v) {
                    setState(() {
                      search_str = v;
                    });
                  },
                  onSubmitted: (v) {
                    setState(() {
                      search_str = v;
                    });
                   
                  },
                  // backgroundColor: Color(0xfffafafa),
                  prefixInsets: EdgeInsets.symmetric(horizontal: 15),
                  suffixInsets: EdgeInsets.symmetric(horizontal: 15),
                  // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  placeholderStyle:
                      TextStyle(fontFamily: "Material", color: Colors.grey),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  // margin: const EdgeInsets.symmetric(horizontal: 15),
                  // decoration: BoxDecoration(
                  //     color: Color(0xfffafafa),
                  //     borderRadius: BorderRadius.circular(10))
    
                  child: isload
                      ? Center(child: CircularProgressIndicator())
                      :  ListView.builder(
              itemCount: list_compo.length,
              itemBuilder: (context, index){
                if(!list_compo[index]["nom"].toString().contains(search_str.trim())){
                  return SizedBox();
                }
               
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 5,
                                color: Colors.grey[300]!)
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7)),
                      width: double.infinity,
                  child: ExpansionTile(
                    title: Text(list_compo[index]["nom"].toString()),
                    children: [
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future:  select_data(
                          "SELECT Distinct Ch.num_chapitre, Ch.Titre, CQ.Avis, Q.questions, CQ.Details, CQ.Date , CQ.Note from Chapitres Ch, Quiz Q, composer_quiz CQ "
    "WHERE Ch.id=Q.id_chapitre AND Q.id=CQ.quiz_id AND CQ.user_id='${list_compo[index]["id"]}' "
    " AND CQ.Details!='' AND Ch.id_cours='${map_data["id"]}'  ORDER BY Ch.num_chapitre ASC, CQ.Avis ASC "
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var t=snapshot.data;
                             if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
        return IntrinsicHeight(
          child: Column(
            children: [
              Center(child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                        child: Text( compter_chapitre(t).toString() +" / "+ list_compo[index]["nbre_chapitre"].toString() +" Chapitre(s) réussi  ", style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(.5) ), ),
                      )),
                      for (var item in t)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        child: InkWell(
                          onTap: () {
                            var list_questions= jsonDecode(item["questions"]);
                            var list_rep= jsonDecode(item["Details"]);
                            showCupertinoModalPopup(context: context, builder : (context)=> AlertDialog(
                              backgroundColor: Colors.white,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                   Flexible(child: Text("Chapitre "+ item["num_chapitre"].toString(), overflow: TextOverflow.ellipsis,)),
                               Text(item["Avis"].toString(), style: TextStyle(color: item["Avis"].toString().toLowerCase()=="echec"? Colors.red: CupertinoColors.activeGreen, 
                              fontWeight: FontWeight.w600
                              ))
                              // Text(item["Note"].toString()+" / 100" ),
                                ],
                              ),
                              actions: [
                                Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                   Flexible(child: Text(item["Date"].toString() ,style: TextStyle(
                                    color: Colors.black45
                                   ) ,overflow: TextOverflow.ellipsis, )),
                                   Text(item["Note"].toString()+" / 100")
                              // Text(item["Note"].toString()+" / 100" ),
                                ],
                              ),
                                // Text(item["Note"].toString()+" / 100")
                              ],
                              content: IntrinsicHeight(
                                child: Column(
                                  children: [
                                    for (var i = 0; i < list_questions.length; i++)
                                                      RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                    text: list_questions[i]["question"].toString() +
                                        " ... ",
                                    style: TextStyle(
                                      color: Colors.black,
                                        // fontSize: 16,
                                        fontFamily: "Circular",
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w500),
                                    children: [
                                      TextSpan(
                                        text:
                                            list_rep[i]["reponse"].toString(),
                                        style: TextStyle(
                                            color: list_rep[i]["reponse"].toString()==list_questions[i]["reponses"][0]? Colors.green : Colors.red,
                                            // fontSize: 15,
                                            fontFamily: "SourceSansPro",
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w400),
                                      )
                                    ])),
                                  
                                  ],
                                ),
                              ),
                            ),
                            
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5) );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item["num_chapitre"].toString()+" . "+ item["Titre"].toString() ),
                              Text(item["Avis"].toString(), style: TextStyle(color: item["Avis"].toString().toLowerCase()=="echec"? Colors.red: CupertinoColors.activeGreen, 
                              fontWeight: FontWeight.w600
                              ),)
                            ],
                          ),
                        ),
                      ),
            ],
          ),
        );
      } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
        showMessage("Erreur", t[0]["error"].toString(), context);
        return SizedBox();
      }else{
        return SizedBox();
    
      }
                          }else{
                            return Center(child: CircularProgressIndicator(),);
                          }
                        
                      }),
                      
                      SizedBox(height: 10,)
                    ] ,
                  ),
                );
              } ))),
         
              ],
            )
             )),
    );
  }

  int compter_chapitre(List<Map<String, dynamic>> li){
    List<String> deja=[];
    int c=0;
    li.forEach((element) { 
       if (element["Avis"].toString().toLowerCase()=="success" && !deja.contains(element["num_chapitre"].toString())) {
      c++;
      deja.add(element["num_chapitre"].toString());
    }
    
    });
   return c;
  }
 
  
}


class AlertActionChapitres extends StatefulWidget {
  Map<String, dynamic> map_data;
  AlertActionChapitres(this.map_data);

  @override
  State<AlertActionChapitres> createState() => AlertActionChapitresState();
}

class AlertActionChapitresState extends State<AlertActionChapitres> {
  bool conf = false;
  String rest = '';
  Timer? timer;
  bool isload = false;
  Function()? click_sup = null;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      setState(() {
        click_sup = demarer_timer;
      });
    });
  }

  void demarer_timer() {
    setState(() {
      conf = true;
      rest = "( 5s )";
    });
    timer = Timer.periodic(Duration(seconds: 1), (timerr) {
      setState(() {
        rest = "( " + (5 - timerr.tick).toString() + "s )";
      });

      if (timerr.tick == 6) {
        setState(() {
          rest = "";
          timerr.cancel();
          click_sup = supression;
        });
      }
    });
    setState(() {
      click_sup = null;
    });
  }

  void supression() async {
    setState(() {
      isload = true;
    });
    var r = await exec_mysql_query(
        "DELETE from Chapitres WHERE id=" + widget.map_data["id"].toString());
    if (r != null && r) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Cours Supprimé ✅")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Une erreur s'est produite ")));
    }
    setState(() {
      isload = false;
    });
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.map_data["Titre"].toString()),
      content: isload
          ? Container(
              height: MediaQuery.of(context).size.height * .4,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Text(
                  "Chapitre : " + widget.map_data["num_chapitre"].toString(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7)),
                  child: CupertinoDialogAction(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) =>
                                      AdminAddChapitre(widget.map_data))))
                          .then((value) {
                        // chargement();
                      });
                    },
                    child: Text("Modifier"),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7)),
                  child: CupertinoDialogAction(
                    onPressed: click_sup,
                    child: Text(conf
                        ? "Confirmer la supression " + rest
                        : "Supprimer " + rest),
                    isDestructiveAction: true,
                  ),
                ),
              ],
            ),
    );
  }
}
