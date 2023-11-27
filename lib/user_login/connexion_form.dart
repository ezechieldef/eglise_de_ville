import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../api_operation.dart';
import '../contantes.dart';

class ConnexionForm extends StatefulWidget {
  @override
  State<ConnexionForm> createState() => _ConnexionFormState();
}

class _ConnexionFormState extends State<ConnexionForm>
    with TickerProviderStateMixin {
  bool passshow = true;

  bool isload = false;
  bool isconnect = false;
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

  Map<String, dynamic> map_saisi = {"Email": null, "Password": ""};
  void connexion() async {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(map_saisi["Email"]);
    if (!emailValid) {
      showMessage('Information', "Veuillez saisir une adress mail valide svp !",
          context);
      return;
    }
    showloading(context);
    var t = await select_data("SELECT * from users where  email='" +
        map_saisi["Email"] +
        "' AND Binary Password='" +
        map_saisi["Password"] +
        "' ");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      try {
        await inserer_local("users", t.first);
        await verif_conn();
      } catch (e) {
        print("connexion echec $e");
        setState(() {
          connected_user = t.first;
        });
      }

      // setState(() {
      //   connected_user = t.first;
      // });
      exitloading(context);
      exitloading(context);
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      exitloading(context);

      showMessage("Erreur", t[0]["error"].toString(), context);
    } else if (t != null && t.isEmpty) {
      exitloading(context);

      showMessage("Désolé",
          "Les informations d'identifications sont incorrectes, ", context);
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
        child: IntrinsicHeight(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                CupertinoTextField(
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  style: themeData.textTheme.headline6,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  placeholder: 'Email',
                  placeholderStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: themeData.textTheme.bodyText1!.color!
                          .withOpacity(.5)),
                  cursorColor: CupertinoColors.activeOrange,
                  onChanged: (v) {
                    setState(() {
                      map_saisi.update("Email", (value) => v.trim());
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
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
                  placeholderStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: themeData.textTheme.bodyText1!.color!
                          .withOpacity(.5)),
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
                  suffix: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          passshow = !passshow;
                        });
                      },
                      icon: Icon(
                        passshow
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        color: Colors.grey,
                      ),
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
                  height: 20,
                ),
                Row(
                  children: [
                    Flexible(child: Divider()),
                    Opacity(
                      opacity: .7,
                      child: Text(
                        "   Mot de Passe oublié ?   ",
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ),
                    Flexible(child: Divider()),
                  ],
                ),

                SizedBox(
                  height: 20,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: MaterialButton(
                    color: CupertinoColors.activeGreen,
                    elevation: 0,
                    textColor: Colors.white,
                    disabledColor: Colors.grey[600],
                    disabledTextColor: Colors.grey,
                    onPressed: map_saisi.containsValue("") ? null : connexion,
                    minWidth: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 7),
                    child: Text(
                      "Se Connecter",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Flexible(child: Divider()),
                    Opacity(
                      opacity: .7,
                      child: Text(
                        "OU",
                      ),
                    ),
                    Flexible(child: Divider()),
                  ],
                ),
                // SizedBox(
                //   height: 15,
                // ),
                // Text(
                //   "Mot de passe oublié ?",
                //   style: TextStyle(color: Colors.grey),
                // ),
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
