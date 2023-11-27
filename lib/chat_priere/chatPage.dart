import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color(0xffFAFAFA),
        elevation: 2,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              CupertinoIcons.left_chevron,
              color: Colors.red,
            )),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Prophete Boris",
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
            Text(
              "Il y a 15 min",
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(children: [
          SizedBox(
            height: 10,
          ),
          Flexible(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return index.isEven
                      ? Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Flexible(
                                  child: Container(
                                width: double.infinity,
                              )),
                              Flexible(
                                flex: 3,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 4),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 7),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Bonsoir !! Comment allez vous ?",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "12/04/2022 15:15",
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    constraints: BoxConstraints(
                                        maxWidth: double.infinity),
                                    decoration: BoxDecoration(
                                        color: Colors.red[500],
                                        border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.01)),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //       color: Colors.black.withOpacity(0.05),
                                        //       blurRadius: 1,
                                        //       offset: Offset(2, 1))
                                        // ],
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Flexible(
                                flex: 3,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 7),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Bonjour !!"),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "12/04/2022 15:15",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  constraints:
                                      BoxConstraints(maxWidth: double.infinity),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color:
                                              Colors.black.withOpacity(0.01)),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 1,
                                            offset: Offset(2, 1))
                                      ],
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                              ),
                              Flexible(
                                  child: Container(
                                width: double.infinity,
                              )),
                            ],
                          ),
                        );
                },
                itemCount: 20,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.only(left: 20, right: 10, top: 7, bottom: 7),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [boxdec_std]),
            child: Row(
              children: [
                Flexible(
                  child: TextFormField(
                    initialValue: "hallo",
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                FloatingActionButton(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  onPressed: () {},
                  child: Icon(
                    FontAwesomeIcons.solidPaperPlane,
                    // size: 20,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
