// import 'dart:js_util';

import 'package:eglise_de_ville/HomePage/Home.dart';
import 'package:eglise_de_ville/admin/admin_contact_us/contact_us.dart';
import 'package:eglise_de_ville/admin/admin_culte/culte.dart';
import 'package:eglise_de_ville/admin/admin_departement/departement.dart';
import 'package:eglise_de_ville/admin/admin_home.dart';
import 'package:eglise_de_ville/admin/admin_programme/programmes.dart';
import 'package:eglise_de_ville/admin/admin_vision/vision.dart';
import 'package:eglise_de_ville/admin/dimes/dimes_home.dart';
import 'package:eglise_de_ville/admin/enseignement/enseignment.dart';
import 'package:eglise_de_ville/admin/gallery/upload_image.dart';
import 'package:eglise_de_ville/admin/lyrics/lyrics_admin.dart';
import 'package:eglise_de_ville/chat_priere/list_chat.dart';
import 'package:eglise_de_ville/comming_soon.dart';
import 'package:eglise_de_ville/contact_us/contact_us.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:eglise_de_ville/departement/departement.dart';
import 'package:eglise_de_ville/enseignement/enseignment.dart';
import 'package:eglise_de_ville/programmes/programmes.dart';
import 'package:eglise_de_ville/vision/vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../contante_var2.dart';
import 'admin_ecole/ecole_home.dart';
import 'menu_screen.dart';

var drawerController = ZoomDrawerController();
// final List<MenuItem> options = [
//   MenuItem(CupertinoIcons.calendar, 'Programmes'),
//   MenuItem(CupertinoIcons.star_fill, 'Discounts'),
//   MenuItem(Icons.notifications, 'Notification'),
//   MenuItem(Icons.format_list_bulleted, 'Orders'),
//   MenuItem(Icons.help, 'Help'),

// ];

class InitDrawerAdmin extends StatefulWidget {
  dynamic home_page;
  InitDrawerAdmin({this.home_page});
  @override
  State<InitDrawerAdmin> createState() => _InitDrawerAdminState();
}

class _InitDrawerAdminState extends State<InitDrawerAdmin> {
  dynamic main_screnn = AdminHome(drawerController);

  void pushr(dynamic p) {
    Navigator.pushAndRemoveUntil(
        context,
        routeTransition(InitDrawerAdmin(home_page: p)),
        // MaterialPageRoute(builder: (context) => ),
        (route) => false);
  }

  Future<bool> _onWillPop() async {
    if (main_screnn.runtimeType.toString() != "AdminHome") {
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
            case "adminprogramme":
              main_screnn = AdminProgramme(drawerController);
              break;
            case "vision":
              main_screnn = AdminVision(drawerController);

              break;
            case "enseignement":
              main_screnn = AdminEnseignement(drawerController);

              break;
            case "département":
              main_screnn = AdminDepartement(drawerController);

              break;
            case "contact":
              // main_screnn = CommingSoon(drawerController);

              main_screnn = AdminContactUs(drawerController);

              break;
            case "gallery":
              main_screnn = UploadImageGallery(drawerController);
              break;
            case "comming soon":
              main_screnn = CommingSoon(drawerController);
              break;
            case "lyrics":
              main_screnn = LyricsAdmin(drawerController);

              break;
            case "culte":
              main_screnn = AdminCulte(drawerController);

              break;
            case "demande de priere":
              main_screnn = CommingSoon(drawerController);

              // main_screnn = HomeChat(drawerController);
              break;
            case "ecole":
              main_screnn = AdminEcole(drawerController);

              // main_screnn = HomeChat(drawerController);
              break;
            case "dimes":
              main_screnn = AdminDimes(drawerController);

              // main_screnn = HomeChat(drawerController);
              break;

            default:
              main_screnn = AdminHome(drawerController);
          }
        });
      } else {
        setState(() {
          main_screnn = AdminHome(drawerController);
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
    return Theme(
      data: themeDatalight,
      child: WillPopScope(
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
      ),
    );
  }
}
