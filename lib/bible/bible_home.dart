import 'package:animations/animations.dart';
import 'package:eglise_de_ville/bible/bible_reading.dart';
import 'package:eglise_de_ville/bible/bible_search.dart';
import 'package:eglise_de_ville/bible/favoris_page.dart';
import 'package:eglise_de_ville/bible/notes_page.dart';
import 'package:eglise_de_ville/bible/surligner_page.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/sqlite_folder/extraction.dart';
import 'package:eglise_de_ville/sqlite_folder/principal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:badges/badges.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BibleHome extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  BibleHome(this.zoomDrawerController);

  @override
  State<BibleHome> createState() => _BibleHomeState();
}

class _BibleHomeState extends State<BibleHome> {
  List<Map<String, dynamic>> list_livres_data = [];
  List<Map<String, dynamic>> list_edition = [];
  int selected_edition = 0;
  bool isload = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initialiser();
  }

  void initialiser() async {
    await preparerCustomisation();
    setState(() {
      isload = true;
    });
    // var db = await executer_transact_sql();
    var t = await select_local_sqlite_bible(
        "SELECT * from Bibles ORDER BY ID ASC", []);
    setState(() {
      list_edition = dupliquer(t);
    });
    charger_livres();
    setState(() {
      isload = false;
    });
  }

  void changer_edition(int new_edit) {
    setState(() {
      selected_edition = new_edit;
    });
    charger_livres();
  }

  void charger_livres({String liblivre = ""}) async {
    setState(() {
      isload = true;
    });
    if (list_edition.isNotEmpty && list_edition.length > selected_edition) {
      var t_name = list_edition[selected_edition]["Table_Name"].toString();
      var t = await select_local_sqlite_bible(
          "SELECT D.Livre, L.Libele, count(DISTINCT D.Chapitre) Chap from $t_name D , Livres L WHERE L.id=D.Livre AND L.Libele LIKE '%'||?||'%' GROUP BY D.Livre ORDER BY D.Livre ASC ",
          [liblivre]);
      setState(() {
        list_livres_data = dupliquer(t);
      });
    }

    setState(() {
      isload = false;
    });
  }

  TextEditingController search_controller = TextEditingController();
  PageController pageController = PageController();
  int selectedpage = 0;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: Container(
          color: isDark() ? Colors.grey[900]! : Color(0xfffafafa),
          padding: const EdgeInsets.all(8.0),
          child: GNav(
              backgroundColor: Colors.transparent,
              selectedIndex: selectedpage,
              onTabChange: (value) {
                pageController.jumpToPage(value);
              },
              rippleColor:
                  Colors.grey[600]!, // tab button ripple color when pressed
              hoverColor: Colors.grey[700]!, // tab button hover color
              haptic: true, // haptic feedback
              tabBorderRadius: 7,
              // tabActiveBorder: Border.all(
              //     color: Colors.black, width: 1), // tab button border
              // tabBorder: Border.all(
              //     color: Colors.grey.withOpacity(.1),
              //     width: 1), // tab button border
              // tabShadow: [
              //   BoxShadow(
              //       color: Colors.grey.withOpacity(0.5), blurRadius: 8)
              // ], // tab button shadow
              curve: Curves.easeOutExpo, // tab animation curves
              duration: Duration(milliseconds: 300), // tab animation duration
              gap: 8, // the tab button gap between icon and text
              color: textColor().withOpacity(.7), // unselected icon color
              activeColor: Colors.deepOrange, // selected icon and text color
              iconSize: 24, // tab button icon size

              tabBackgroundColor: CupertinoColors.activeOrange
                  .withOpacity(0.1), // selected tab background color
              padding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: 5), // navigation bar padding
              tabs: [
                GButton(
                  icon: Icons.book_rounded,
                  text: 'Livres',
                ),
                GButton(
                  icon: Icons.filter_list,
                  text: 'Mes Notes',
                ),
                GButton(
                  icon: Icons.history_toggle_off_rounded,
                  text: 'Surligner',
                ),
                GButton(
                  icon: Icons.favorite,
                  text: 'Favoris',
                )
              ]),
        ),
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
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BibleSearch({
                                "Mot": "",
                                "Version": list_edition[selected_edition]
                                    ["Table_Name"],
                                "VersionName": list_edition[selected_edition]
                                    ["Version"]
                              })));
                },
                icon: Icon(
                  // CupertinoIcons.square_arrow_down_on_square_fill,
                  CupertinoIcons.search,
                  color: Colors.grey[700],
                ))
          ],
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
                  ),
                  // TextSpan(
                  //   text: ' : Bible',
                  //   style: TextStyle(
                  //     color: Colors.black54,
                  //     // color: Colors.black,
                  //     fontWeight: FontWeight.w500,
                  //     // fontSize: 14,
                  //   ),
                  // )
                ]),
          ),
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            child: PageView(
              controller: pageController,
              onPageChanged: (page) {
                setState(() {
                  selectedpage = page;
                });
              },
              children: [
                get_home_page(),
                const NotePage(),
                const SurlignerPage(),
                const FavorisPage()
              ],
            )),
      ),
    );
  }

  Color get_color(int index) {
    List<Map<String, dynamic>> color_list = [
      {"c": Colors.pink, "t": Colors.black},

      {"c": Colors.orange, "t": Colors.black},
      {"c": Colors.blue, "t": Colors.black},
      {"c": Colors.green[500], "t": Colors.black},
      // {"c": Colors.brown, "t": Colors.black},
    ];

    while (index > color_list.length - 1) {
      index -= color_list.length;
    }
    return color_list[index]["c"];
  }

  Widget get_home_page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 5,
        ),
        Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < list_edition.length; i++)
                    InkWell(
                      onTap: () {
                        changer_edition(i);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Colors.grey[200]!, blurRadius: 2)
                          ],
                          borderRadius: BorderRadius.circular(4),
                          color: selected_edition == i
                              ? CupertinoColors.activeGreen
                              : Colors.white,
                        ),
                        child: Text(
                          list_edition[i]["Version"].toString(),
                          style: TextStyle(
                            color: selected_edition == i
                                ? CupertinoColors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            )),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: CupertinoSearchTextField(
            controller: search_controller,
            // backgroundColor: Colors.grey[200],
            style: TextStyle(
                fontFamily: "Material", fontSize: 14, color: textColor()),

            placeholderStyle: TextStyle(
                fontFamily: "Material",
                fontSize: 14,
                color: textColor().withOpacity(.7)),

            // backgroundColor: Colors.white,
            prefixIcon: Icon(CupertinoIcons.doc_text_search),
            placeholder: "Rechercher un Livre ",
            onChanged: (v) {
              if (v.trim().isNotEmpty) {
                charger_livres(liblivre: v);
              }
            },
            onSubmitted: (v) {
              charger_livres(liblivre: v);
            },
            onSuffixTap: () {
              charger_livres(liblivre: "");
              search_controller.clear();
            },
            prefixInsets: EdgeInsets.symmetric(horizontal: 15),
            suffixInsets: EdgeInsets.symmetric(horizontal: 15),
            // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Flexible(
            child: Container(
          width: double.infinity,
          height: double.infinity,
          child: isload
              ? Center(child: CupertinoActivityIndicator())
              : isload
                  ? Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : list_livres_data.isEmpty
                      ? Column(
                          children: [
                            SizedBox(
                              height: 25,
                            ),
                            Text("Aucune correspondances : " +
                                search_controller.text),
                            SizedBox(
                              height: 15,
                            ),
                            Flexible(
                              child: LottieBuilder.asset(
                                  "assets/lotties/lf20_n2m0isqh.json"),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: list_livres_data.length,
                          itemBuilder: (context, index) {
                            return Container(
                              // padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                              margin: EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 15),
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
                                      ? Colors.white.withOpacity(.3)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(7)),
                              width: double.infinity,
                              child: Theme(
                                data: Theme.of(context)
                                    .copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  childrenPadding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  // leading: Container(
                                  //   padding: EdgeInsets.all(8),
                                  //   decoration: BoxDecoration(
                                  //       color: get_color(i)["c"],
                                  //       borderRadius: BorderRadius.circular(10)),
                                  //   child: Icon(
                                  //     Icons.back_hand,
                                  //     color: Colors.white,
                                  //     size: 22,
                                  //   ),
                                  // ),
                                  trailing: (list_livres_data[index]["Livre"] >
                                          39)
                                      ? Badge(
                                          child: Text(
                                            list_livres_data[index]["Chap"]
                                                    .toString() +
                                                " Chapitre(s)",
                                            style: TextStyle(
                                                color:
                                                    CupertinoColors.activeGreen
                                                //  get_color(index)
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          toAnimate: true,
                                          position: BadgePosition.topEnd(),
                                          // stackFit: StackFit.expand,
                                          shape: BadgeShape.circle,
                                          badgeColor: Colors.red[500]!,
                                          padding: EdgeInsets.all(3.5),
                                          alignment: Alignment.centerLeft,
                                          elevation: 0,
                                          badgeContent: Text('',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white)),
                                        )
                                      : Text(
                                          list_livres_data[index]["Chap"]
                                                  .toString() +
                                              " Chapitre(s)",
                                          style: TextStyle(
                                              color: CupertinoColors.activeGreen
                                              //  get_color(index)
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  title: Text(list_livres_data[index]["Libele"]
                                      .toString()),

                                  children: [
                                    GridView.count(
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      crossAxisCount: 7,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                      children: [
                                        for (var i = 0;
                                            i <
                                                int.parse(
                                                    list_livres_data[index]
                                                            ["Chap"]
                                                        .toString());
                                            i++)
                                          OpenContainer(
                                            closedElevation: 0,
                                            transitionDuration:
                                                Duration(milliseconds: 500),
                                            openBuilder: (((context, action) =>
                                                ReadCharpenterBible({
                                                  "Table": list_edition[
                                                              selected_edition]
                                                          ["Table_Name"]
                                                      .toString(),
                                                  "Version": list_edition[
                                                              selected_edition]
                                                          ["Version"]
                                                      .toString(),
                                                  "LibLivre":
                                                      list_livres_data[index]
                                                          ["Libele"],
                                                  "Livre":
                                                      list_livres_data[index]
                                                          ["Livre"],
                                                  "Chapitre": i + 1,
                                                  "MaxChapitre":
                                                      list_livres_data[index]
                                                          ["Chap"]
                                                }))),
                                            closedBuilder:
                                                (BuildContext context,
                                                    void Function() action) {
                                              return Container(
                                                width: double.infinity,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3)),
                                                child: Center(
                                                    child: Text(
                                                  (i + 1).toString(),
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                )),
                                              );
                                            },
                                          )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
        ))
      ],
    );
  }
}
