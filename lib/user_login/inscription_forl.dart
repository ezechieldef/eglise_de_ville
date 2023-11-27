import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../api_operation.dart';
import '../contante_var2.dart';
import '../sqlite_folder/principal.dart';

class InscriptionForm extends StatefulWidget {
  @override
  State<InscriptionForm> createState() => _InscriptionFormState();
}

class _InscriptionFormState extends State<InscriptionForm>
    with TickerProviderStateMixin {
  bool passshow = true;

  bool isload = false;
  bool isconnect = false;

  Map<String, dynamic> map_saisi = {"Email": "", "Password": "", "Nom": ""};
  AnimationController? _controller;
  Animation<Offset>? _animation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, 10.0),
      end: const Offset(0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.decelerate,
    ));
    _controller!.reset();
    _controller!.forward();
  }

  void inscription() async {
    if (map_saisi["Nom"].toString().split(" ").length <= 1) {
      showMessage('Information',
          "Veuillez saisir votre nom et votre prénom svp !", context);
      return;
    }
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(map_saisi["Email"]);
    if (!emailValid) {
      showMessage('Information', "Veuillez saisir une adress mail valide svp !",
          context);
      return;
    }
    showloading(context);
    var t = await select_data(
        "SELECT * from users where email='" + map_saisi["Email"] + "'");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      print("p1");
      exitloading(context);

      showMessage(
          "Information",
          "Vous êtes déjà inscrit, rendez-vous dans l'onglet 'Connexion' pour vous connecter.\nSi vous avez oublié votre mot de passe, vous pouvez le réinitialiser dans le même onglet",
          context);
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      print("p2");
      exitloading(context);

      showMessage("Erreur", t[0]["error"].toString(), context);
    } else if (t != null && t.isEmpty) {
      Map<String, dynamic> conn = await insert_data_get_id(map_saisi, "users");

      if (conn["status"] != "OK") {
        exitloading(context);
        showMessage("Désolé", conn["message"].toString(), context);

        return;
      } else {
        // print(conn);
        
        map_saisi.putIfAbsent("id", () => int.parse(conn["ID"].toString()));
        map_saisi.putIfAbsent("email", () => map_saisi["Email"].toString());
        map_saisi.putIfAbsent("nom", () => map_saisi["Nom"].toString());
        
        if (map_saisi.containsKey("id")) {
          map_saisi.remove("id");
        }
        if (map_saisi.containsKey("Nom")) {
          map_saisi.remove("Nom");
        }
        if (map_saisi.containsKey("Email")) {
          map_saisi.remove("Email");
        }
        // setState(() {
        //   connected_user = map_saisi;
        // });
        print("inscrip $map_saisi");
      try {
        await inserer_local("users", map_saisi);
        await verif_conn();
      } catch (e) {
        setState(() {
          connected_user=map_saisi;
        });
      }
      
        exitloading(context);
        exitloading(context);

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Inscription Réussi ✅")));
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _controller!.dispose();
    _animation = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                CupertinoTextField(
                  style: themeData.textTheme.headline6,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  placeholder: 'Nom et Prénoms',
                  placeholderStyle: TextStyle(fontWeight: FontWeight.w400, color: themeData.textTheme.bodyText1!.color!.withOpacity(.5) ),
                  cursorColor: CupertinoColors.activeOrange,
                  onChanged: (v) {
                    setState(() {
                      map_saisi.update("Nom", (value) => v.trim());
                    });
                  },
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.person_alt,
                      color: Colors.grey,
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: isDark()
                          ? Colors.white.withOpacity(.4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        isDark()
                            ? BoxShadow()
                            : BoxShadow(blurRadius: 4, color: Colors.grey[200]!)
                      ]
                      // border: Border.all(color: Colors.grey[200]!, width: 1.5)
                      ),
                ),
                SizedBox(
                  height: 15,
                ),
                CupertinoTextField(
                  style: themeData.textTheme.headline6,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  placeholder: 'Email',
                  placeholderStyle: TextStyle(fontWeight: FontWeight.w400, color: themeData.textTheme.bodyText1!.color!.withOpacity(.5) ),
                  cursorColor: CupertinoColors.activeOrange,
                  onChanged: (v) {
                    setState(() {
                      map_saisi.update("Email", (value) => v.trim());
                    });
                  },
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.at,
                      color: Colors.grey,
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: isDark()
                          ? Colors.white.withOpacity(.4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        isDark()
                            ? BoxShadow()
                            : BoxShadow(blurRadius: 4, color: Colors.grey[200]!)
                      ]
                      // border: Border.all(color: Colors.grey[200]!, width: 1.5)
                      ),
                ),
                SizedBox(
                  height: 15,
                ),
                CupertinoTextField(
                  style: themeData.textTheme.headline6,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  placeholder: 'Mot de Passe',
                  placeholderStyle: TextStyle(fontWeight: FontWeight.w400, color: themeData.textTheme.bodyText1!.color!.withOpacity(.5) ),
                  onChanged: (v) {
                    setState(() {
                      map_saisi.update("Password", (value) => v);
                    });
                  },
                  cursorColor: CupertinoColors.activeOrange,
                  obscureText: passshow,
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.lock,
                      color: Colors.grey,
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: isDark()
                          ? Colors.white.withOpacity(.4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        isDark()
                            ? BoxShadow()
                            : BoxShadow(blurRadius: 4, color: Colors.grey[200]!)
                      ]
                      // border: Border.all(color: Colors.grey[200]!, width: 1.5)
                      ),
                ),
                SizedBox(
                  height: 30,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: MaterialButton(
                    color: CupertinoColors.activeGreen,
                    elevation: 0,
                    textColor: Colors.white,
                    disabledColor: Colors.grey[600],
                    disabledTextColor: Colors.grey,
                    onPressed: map_saisi.containsValue("") ? null : inscription,
                    minWidth: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 7),
                    child: Text(
                      "S'inscrire",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get_rounded_back(Widget child) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(100),
      ),
      child: child,
    );
  }
}
