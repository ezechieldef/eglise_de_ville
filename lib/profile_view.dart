import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  void deconnec() {
    showModal(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        context: context,
        builder: (context) => Theme(
              data: themeData,
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                content: IntrinsicHeight(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: isDark() ? Colors.grey[900] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: textColor()),
                            width: 150,
                            height: 150,
                            transform:
                                Matrix4.translationValues(0, -150 / 2, 0),
                            child: Center(
                              child: connected_user['photo'].toString() != ""
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(200),
                                      child: Image.network(
                                        connected_user['photo'],
                                        width: 150,
                                        height: 150,
                                      ),
                                    )
                                  : Icon(
                                      CupertinoIcons.person_alt_circle_fill,
                                      color: isDark()
                                          ? Colors.black
                                          : Colors.white,
                                      size: 150,
                                    ),
                            )),
                        Transform(
                          transform: Matrix4.translationValues(0, -40, 0),
                          child: Text(
                            (camelCase(connected_user['nom'] ?? "")),
                            style: TextStyle(
                                color: textColor(),
                                fontSize: 20,
                                fontFamily: "Circular",
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Transform(
                          transform: Matrix4.translationValues(0, -15, 0),
                          child: Text(
                            (connected_user['email']),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: textColor().withOpacity(.4),
                                fontFamily: "Circular",
                                fontSize: 15),
                          ),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            await select_local_sqlite(
                                "DELETE FROM users WHERE 1", []);
                            setState(() {
                              connected_user = {};
                            });

                            await googleLogout();

                            setState(() {
                              googleUser = null;
                            });
                            exitloading(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Déconnexion réussi")));
                          },
                          minWidth: double.infinity,
                          textColor: Colors.white,
                          color: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text("Se déconnecter"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return connected_user.isEmpty
        ? SizedBox()
        : InkWell(
            onTap: deconnec,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 7),
              decoration: BoxDecoration(
                  color: isDark()
                      ? Colors.grey[100]!.withOpacity(.3)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  connected_user['photo'] != ""
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: Image.network(
                            connected_user['photo'],
                            width: 50,
                            height: 50,
                          ),
                        )
                      : Icon(
                          CupertinoIcons.person_alt_circle_fill,
                          color: textColor(),
                          size: 35,
                        ),
                  SizedBox(
                    width: 15,
                  ),
                  Flexible(
                    child: SizedBox(
                      width: double.infinity,
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              camelCase(connected_user['nom']),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: textColor(),
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              connected_user['email'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor().withOpacity(.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
