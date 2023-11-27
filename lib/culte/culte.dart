import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lecle_flutter_link_preview/lecle_flutter_link_preview.dart';
// import 'package:neplox_linkpreviewer/neplox_linkpreviewer.dart';
// import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:url_launcher/url_launcher.dart' as ul;
import 'package:intl/intl.dart';
import '../api_operation.dart';
import '../contante_var2.dart';
import '../contantes.dart';

class CultePage extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  CultePage(this.zoomDrawerController);

  @override
  State<CultePage> createState() => _CultePageState();
}

class _CultePageState extends State<CultePage> {
  List<Map<String, dynamic>> list_culte = [];
  bool isload = false;
  TextEditingController search_controller = TextEditingController();
  Future<void> chargement({String search = ""}) async {
    setState(() {
      isload = true;
      list_culte = [];
    });

    var t = await select_data(
        "SELECT * from Cultes WHERE Titre LIKE '%$search%' or Date LIKE '%$search%' ORDER BY Date DESC");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_culte = t;
      });
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage("Erreur", t[0]["error"].toString(), context);
    }
    setState(() {
      isload = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargement();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: RefreshIndicator(
        onRefresh: chargement,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    themeData = isDark() ? themeDatalight : themeDatadark;
                  });
                },
                icon: Icon(
                  isDark()
                      ? CupertinoIcons.sun_max_fill
                      : CupertinoIcons.moon_stars_fill,
                  color: themeData.iconTheme.color!.withOpacity(.7),
                ),
              )
            ],
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
            // margin: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: Text(
                    "Cultes".toUpperCase(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: textColor().withOpacity(.7),
                        // fontSize: 13,
                        // letterSpacing: 1.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: CupertinoSearchTextField(
                    controller: search_controller,
                    suffixMode: OverlayVisibilityMode.always,
                    style: TextStyle(fontFamily: "Material", fontSize: 14),
                    // backgroundColor: Colors.white,
                    placeholder: "Rechercher ...",
                    onSubmitted: (v) {
                      chargement(search: v);
                    },
                    suffixIcon: Icon(CupertinoIcons.calendar_today),
                    onSuffixTap: () async {
                      var pic = await showDatePicker(
                          context: context,
                          locale: Locale("fr"),
                          initialDate: DateTime.now(),
                          firstDate:
                              DateTime.now().subtract(Duration(days: 365 * 5)),
                          lastDate: DateTime.now().add(Duration(days: 30)));
                      if (pic != null) {
                        search_controller.text =
                            pic.toString().split(" ").first;

                        chargement(search: pic.toString().split(" ").first);
                      }
                    },
                    prefixInsets: EdgeInsets.symmetric(horizontal: 15),
                    suffixInsets: EdgeInsets.symmetric(horizontal: 15),
                    // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    placeholderStyle:
                        TextStyle(fontFamily: "Material", color: Colors.grey),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Flexible(
                  child: isload
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              for (var i = 0; i < list_culte.length; i++)
                                Container(
                                    // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                                    margin: EdgeInsets.symmetric(
                                        vertical: 7, horizontal: 17),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          isDark()
                                              ? BoxShadow()
                                              : BoxShadow(
                                                  offset: Offset(0, 0),
                                                  blurRadius: 5,
                                                  color: Colors.grey[300]!)
                                        ],
                                        color: isDark()
                                            ? Colors.white.withOpacity(.4)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(7)),
                                    width: double.infinity,
                                    child: ListTile(
                                      minVerticalPadding: 15,
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      title: Text(
                                        list_culte[i]["Titre"].toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: Column(
                                          children: [
                                            // SizedBox(
                                            //   height: 10,
                                            // ),
                                            ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: FlutterLinkPreview(
                                                    url: list_culte[i]["Lien"]
                                                        .toString(),
                                                    titleStyle: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ))),

// SimpleUrlPreview(
//                                                   elevation: 0,
//                                                   siteNameStyle: TextStyle(
//                                                       color: Colors.blue,
//                                                       fontWeight:
//                                                           FontWeight.w600),
//                                                   bgColor: Colors.green[100]!
//                                                       .withOpacity(0.6),
//                                                   imageLoaderColor: Colors.red,
//                                                   descriptionStyle: TextStyle(
//                                                       color: isDark()
//                                                           ? Colors.white
//                                                               .withOpacity(.8)
//                                                           : Colors.blue),
//                                                   titleStyle: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                       fontSize: 15),
//                                                   url: list_culte[i]["Lien"]
//                                                       .toString()),
//                                             )

                                            SizedBox(
                                              height: 7,
                                            ),
                                            Text(
                                              camelCase(
                                                  DateFormat.yMMMMEEEEd("fr")
                                                      .format(DateTime.parse(
                                                          list_culte[i]["Date"]
                                                              .toString()))),
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  // fontFamily: "Material",
                                                  // fontSize: 12,
                                                  // fontStyle: FontStyle.italic,
                                                  // fontWeight: FontWeight.w600,
                                                  color: Colors.grey[500]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                            ],
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

  Map<String, dynamic> get_color(int index) {
    List<Map<String, dynamic>> color_list = [
      {"c": Colors.red, "t": Colors.black},
      {"c": Colors.grey[800], "t": Colors.black},

      {"c": Colors.orange, "t": Colors.black},

      {"c": Colors.blueGrey, "t": Colors.black},
      {"c": Colors.green[400], "t": Colors.black},
      {"c": Colors.brown, "t": Colors.black},

      // {"c": Colors.grey[100], "t": Colors.black},
    ];

    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    return color_list[index];
  }
}
