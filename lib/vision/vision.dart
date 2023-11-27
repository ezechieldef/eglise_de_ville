import 'dart:convert';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_quill/flutter_quill.dart' as fq;

import '../api_operation.dart';
import '../sqlite_folder/principal.dart';

class VisionPage extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  VisionPage(this.zoomDrawerController);

  @override
  State<VisionPage> createState() => _VisionPageState();
}

class _VisionPageState extends State<VisionPage> {
  fq.QuillController _controller = fq.QuillController.basic();
  bool isload = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargement();
  }

  void chargement() async {
    if (mounted)
      setState(() {
        isload = true;
      });
    var t = await select_data('SELECT * from Vision ORDER BY id Desc LIMIT 1');

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      await inserer_local_list("Vision", t);
      _controller = fq.QuillController(
          document: fq.Document.fromJson(jsonDecode(t[0]["Contenu"])),
          selection: TextSelection.collapsed(offset: 0));
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      // showMessage("Erreur", t[0]["error"].toString(), context);
      showMessage("Avertissement", internet_off_str, context);

      try {
        var t2 = await select_local_sqlite(
            'SELECT * from Vision ORDER BY id Desc LIMIT 1', []);
        if (t2.isNotEmpty) {
          _controller = fq.QuillController(
              document: fq.Document.fromJson(jsonDecode(t2[0]["Contenu"])),
              selection: TextSelection.collapsed(offset: 0));
        }
      } catch (e) {
        print(e);
      }
    }

    if (mounted)
      setState(() {
        isload = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                widget.zoomDrawerController.toggle!();
              },
              icon: Icon(
                Icons.menu,
                color: Colors.red,
              )),
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: 'EGLISE ',
                style: TextStyle(color: textColor(), fontFamily: "Montserrat"
                    // color: Colors.black,
                    // fontSize: 14,
                    ),
                children: [
                  TextSpan(
                    text: 'DE ',
                    style: TextStyle(
                      color: Colors.red[200],
                      // color: Colors.black,
                      fontWeight: FontWeight.w600,
                      // fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: 'VILLE',
                    style: TextStyle(
                      color: Colors.red,
                      // color: Colors.black,
                      fontWeight: FontWeight.w600,
                      // fontSize: 14,
                    ),
                  )
                ]),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                          colors: [Colors.red, Colors.red[800]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Vision".toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              // letterSpacing: 1.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text("Matthieu 5:14",
                          style: TextStyle(
                              color: Colors.white,
                              // letterSpacing: 1.0,
                              fontWeight: FontWeight.w600)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          "Vous êtes la lumière du monde. Une ville située sur une montagne ne peut être cachée.",
                          style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                // Center(
                //   child: CircularProgressIndicator(),
                // ),
                isload
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : IntrinsicHeight(
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          child: fq.QuillEditor(
                            controller: _controller,
                            scrollController: ScrollController(),
                            scrollable: true,
                            focusNode: FocusNode(),
                            autoFocus: false,
                            readOnly: true,
                            expands: false,
                            padding: EdgeInsets.zero,
                            showCursor: false, // true for view only mode
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
