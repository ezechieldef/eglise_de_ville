import 'dart:convert';

// import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminVision extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  AdminVision(this.zoomDrawerController);

  @override
  State<AdminVision> createState() => _AdminVisionState();
}

class _AdminVisionState extends State<AdminVision> {
  fq.QuillController _controller = fq.QuillController.basic();
  bool isload = false;
  int _current_idex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargement();
  }

  void chargement() async {
    setState(() {
      isload = true;
    });
    var t = await select_data('SELECT * from Vision ORDER BY id Desc LIMIT 1');

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      _controller = fq.QuillController(
          document: fq.Document.fromJson(jsonDecode(t[0]["Contenu"])),
          selection: TextSelection.collapsed(offset: 0));
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage("Erreur", t[0]["error"].toString(), context);
    }
    setState(() {
      isload = false;
    });
  }

  void btn_send() async {
    setState(() {
      isload = true;
    });
    Map<String, dynamic> conn = await insert_data({
      "id": 1,
      "Contenu": jsonEncode((_controller.document.toDelta().toJson())),
      "Date": DateTime.now().toString()
    }, "Vision");

    if (conn["status"] != "OK") {
      setState(() {
        isload = false;
      });
      showMessage("Désolé", conn["message"].toString(), context);

      return;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enseignement Ajouté ✅")));
    }
    setState(() {
      isload = false;
    });
    exitloading(context);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(primarySwatch: Colors.green, brightness: Brightness.light),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        // bottomNavigationBar: bottom,
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          elevation: 0,
          // backgroundColor: Colors.green,
          // shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(Radius.circular(15.0))),
          onPressed: () {
            btn_send();
          },
          child: Icon(
            FontAwesomeIcons.solidPaperPlane,
            // size: 20,
            color: Colors.white,
          ),
        ),
        appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: IconButton(
                onPressed: () {
                  widget.zoomDrawerController.toggle!();
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.green,
                )),
            actions: [
              IconButton(
                  onPressed: () {
                    chargement();
                  },
                  icon: Icon(
                    CupertinoIcons.refresh_circled_solid,
                    color: Colors.grey,
                  ))
            ],
            title: Text(
              "Eglise de ville".toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontFamily: "Montserrat",
                color: Colors.green[500]!,
                // color: Colors.grey[700]
              ),
            )),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          margin: EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: fq.QuillToolbar.basic(controller: _controller)),
              SizedBox(
                height: 20,
              ),
              Flexible(
                child: isload
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: fq.QuillEditor.basic(
                          controller: _controller,
                          readOnly: false, // true for view only mode
                        ),
                      ),
              ),
              // SizedBox(height: 55)
            ],
          ),
        ),
      ),
    );
  }
}
