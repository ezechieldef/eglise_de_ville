// import 'dart:js_util';

import 'package:eglise_de_ville/Ecole_Biblique/EcoleBiblique.dart';
import 'package:eglise_de_ville/HomePage/Home.dart';
import 'package:eglise_de_ville/bible/bible_home.dart';
import 'package:eglise_de_ville/chat_priere/list_chat.dart';
import 'package:eglise_de_ville/comming_soon.dart';
import 'package:eglise_de_ville/contact_us/contact_us.dart';
import 'package:eglise_de_ville/culte/culte.dart';
import 'package:eglise_de_ville/departement/departement.dart';
import 'package:eglise_de_ville/dimes/dimes_home.dart';
import 'package:eglise_de_ville/don/don_acccueil.dart';
import 'package:eglise_de_ville/ecole/ecole_home.dart';
import 'package:eglise_de_ville/enseignement/enseignment.dart';
import 'package:eglise_de_ville/gallery/home_gallery.dart';
import 'package:eglise_de_ville/lyrics/lyrics_home.dart';
import 'package:eglise_de_ville/programmes/programmes.dart';
import 'package:eglise_de_ville/vision/vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import 'main.dart';
import 'menu_screen.dart';

class MenuItem {
  String title;
  IconData icon;
  MenuItem(this.icon, this.title);
}

final drawerController = ZoomDrawerController();
// final List<MenuItem> options = [
//   MenuItem(CupertinoIcons.calendar, 'Programmes'),
//   MenuItem(CupertinoIcons.star_fill, 'Discounts'),
//   MenuItem(Icons.notifications, 'Notification'),
//   MenuItem(Icons.format_list_bulleted, 'Orders'),
//   MenuItem(Icons.help, 'Help'),

// ];

class InitDrawer extends StatefulWidget {
  dynamic home_page;
  InitDrawer({this.home_page});
  @override
  State<InitDrawer> createState() => _InitDrawerState();
}

class _InitDrawerState extends State<InitDrawer> implements listenerHome {
  dynamic main_screnn = HomePage2(drawerController);

  void pushr(dynamic p) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => InitDrawer(home_page: p)),
        (route) => false);
  }

  Future<bool> _onWillPop() async {
    if (main_screnn.runtimeType.toString() != "HomePage2") {
      print("here " + main_screnn.runtimeType.toString());
      pushr("");
      return false;
    }

    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (widget.home_page != null) {
        setState(() {
          switch (widget.home_page.toString().toLowerCase()) {
            case "programme":
              main_screnn = ProgramePage(drawerController);
              break;
            case "vision":
              main_screnn = VisionPage(drawerController);
              break;
            case "enseignement":
              main_screnn = EnseignementPage(drawerController);
              break;
            case "département":
              main_screnn = DepartementPage(drawerController);
              break;
            case "contact":
              main_screnn = ContactUs(drawerController);

              break;
            case "comming soon":
              main_screnn = CommingSoon(drawerController);

              break;
            case "demande de priere":
              main_screnn = HomeChat(drawerController);
              break;
            case "galerie":
              main_screnn = GalleryPhoto(drawerController);
              break;

            case "don":
              main_screnn = DonAccueil(drawerController);
              break;
            case "lyrics":
              main_screnn = LyricsHome(drawerController);
              break;
            case "culte":
              main_screnn = CultePage(drawerController);
              break;
            case "bible":
              main_screnn = BibleHome(drawerController);
              break;
            case "ecole":
              main_screnn = EcoleHome(drawerController);
              break;
            case "dimes":
              main_screnn = DimesHome(drawerController);
              break;
            case "ecole biblique":
              main_screnn = EcoleBiblique(drawerController);

              break;
            default:
              main_screnn = HomePage2(drawerController);
          }
        });
      } else {
        setState(() {
          main_screnn = HomePage2(drawerController);
        });
      }
    });
  }

  void set_main(dynamic p) {
    setState(() {
      main_screnn = p;
      drawerController.toggle!();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xff282828),
            // gradient: LinearGradient(
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     colors: [Colors.grey[800]!, Colors.black])
          ),
          child: ZoomDrawer(
            controller: drawerController,
            menuScreen: DrawerScreen("Accueil", this),
            mainScreen: main_screnn,
            borderRadius: 24,
            // slideWidth: MediaQuery.of(context).size.width * 0.7,
            // style: DrawerStyle.style3,
            shrinkMainScreen: false,
            // openCurve: Curves.fastOutSlowIn,
            drawerShadowsBackgroundColor: Colors.red,
            duration: Duration(milliseconds: 300),
            reverseDuration: Duration(milliseconds: 300),
            // menuScreenOverlayColor: Colors.purple,

            showShadow: true,
            angle: 0,
          ),
        ),
      ),
    );
  }

  @override
  void click_menu(pageName) {
    setState(() {
      main_screnn = pageName;
      print("c'est fait ");
    });
  }
}
