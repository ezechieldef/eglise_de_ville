import 'package:eglise_de_ville/chat_priere/chatPage.dart';
import 'package:eglise_de_ville/chat_priere/newChatAlert.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';

class HomeChat extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  HomeChat(this.zoomDrawerController);
  @override
  State<HomeChat> createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> {
  List<dynamic> list_discuss = [{}, {}, {}];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // backgroundColor: Color.fromARGB(255, 255, 247, 247),
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              widget.zoomDrawerController.toggle!();
            },
            icon: Icon(
              Icons.menu,
              color: Colors.red,
            )),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.bell,
                color: Colors.grey,
              ))
        ],
        title: Text(
          "Eglise de ville",
          style: TextStyle(
            fontFamily: "Awake",
            color: Colors.red[600]!,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (c) => NewChatDialog());
        },
        child: Icon(Icons.add),
      ),
      body: Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Discussions",
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.grey[700],
                fontSize: 20,
                // letterSpacing: 1.0,
                fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Flexible(
            child: Container(
          width: double.infinity,
          height: double.infinity,
          child: ListView.separated(
              itemBuilder: ((context, index) {
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      // boxShadow: [boxdec_std],
                      borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => ChatPage()));
                    },
                    child: ListTile(
                      minLeadingWidth: 35,
                      title: Text("Titre du sujet"),
                      subtitle: Text("Dernier message"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          index.isEven
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 4),
                                  child: Text(
                                    "Fermer",
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey),
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.grey[100]))
                              : Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 4),
                                  child: Text(
                                    "$index",
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.white),
                                  ),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red[600])),
                          Text(
                            "12 Avril 2022",
                            style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey),
                          )
                        ],
                      ),
                      leading: Container(
                          width: 35,
                          height: 35,
                          alignment: Alignment.center,
                          child: Text(
                            "PB",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          decoration: BoxDecoration(
                              // shape: BoxShape.circle,
                              borderRadius: BorderRadius.circular(7),
                              // color: get_color(index)["c"],
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    // get_color(0)["c"],
                                    // get_color(0)["f"]
                                    Colors.grey[700]!,
                                    // Colors.grey[900]!,
                                    Colors.red[800]!
                                  ]))),
                    ),
                  ),
                );
              }),
              separatorBuilder: (context, index) {
                return Divider(
                  height: 5,
                  indent: 20,
                  endIndent: 20,
                  color: Colors.red[100]!.withOpacity(0.8),
                );
              },
              itemCount: list_discuss.length),
        ))
      ])),
    );
  }

  Map<String, dynamic> get_color(int index) {
    List<Map<String, dynamic>> color_list = [
      {"c": Colors.orange, "t": Colors.black, "f": Colors.orange[800]},
      {"c": Colors.blue, "t": Colors.black, "f": Colors.blue[800]},
      {"c": Colors.green, "t": Colors.black, "f": Colors.green[700]},
      {"c": Colors.purple, "t": Colors.black, "f": Colors.purple[800]},
      {"c": Colors.pink[400], "t": Colors.black, "f": Colors.pink[600]},
      // {"c": Colors.orange[300], "t": Colors.black},
      // {"c": Colors.grey[100], "t": Colors.black},
    ];

    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    return color_list[index];
  }
}
