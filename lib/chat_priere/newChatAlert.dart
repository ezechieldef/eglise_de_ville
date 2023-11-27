import 'dart:ui';

import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/material.dart';

class NewChatDialog extends StatefulWidget {
  @override
  State<NewChatDialog> createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<NewChatDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              // width: MediaQuery.of(context).size.width * 0.75,
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),

              // height: MediaQuery.of(context).size.height * 0.75,
              child: Wrap(
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Sujet "),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Colors.grey[200],
                          ),
                          child: DropdownButton(
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(10),
                              // dropdownColor: Colors.red,
                              // focusColor: Colors.red[100],
                              underline: SizedBox(),
                              items: [
                                for (var i = 0; i < 4; i++)
                                  DropdownMenuItem(
                                    child: Text("Sujet Populaire $i"),
                                    value: i,
                                  )
                              ],
                              onChanged: (v) {}),
                        ),
                        Text("Message"),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 7),
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Colors.grey[200],
                          ),
                          child: TextFormField(
                            minLines: 3,
                            maxLines: 5,
                            decoration:
                                InputDecoration(border: InputBorder.none),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MaterialButton(
                                  color: Colors.grey[100],
                                  textColor: Colors.black,
                                  onPressed: () {},
                                  minWidth: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Annuler".toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MaterialButton(
                                  color: Colors.red,
                                  textColor: Colors.white,
                                  onPressed: () {},
                                  minWidth: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Envoyer".toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                ],
              ),
            )));
  }
}
