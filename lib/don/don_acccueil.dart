import 'dart:ui';

import 'package:eglise_de_ville/contante_var2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kkiapay_flutter_sdk/kkiapay/view/widget_builder_view.dart';
import 'package:overlay_support/overlay_support.dart';

import '../contantes.dart';
import '../dimes/kkiapay_config.dart';

class DonAccueil extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  DonAccueil(this.zoomDrawerController);

  @override
  State<DonAccueil> createState() => _DonAccueilState();
}

class _DonAccueilState extends State<DonAccueil> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: 'EGLISE ',
                style: TextStyle(color: textColor(), fontFamily: 'Montserrat'
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: Text(
                //     "Don",
                //     textAlign: TextAlign.start,
                //     style: TextStyle(
                //         color: Colors.grey[800],
                //         // fontSize: 13,
                //         // letterSpacing: 1.0,
                //         fontWeight: FontWeight.w600),
                //   ),
                // ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
                    child: Text(
                      "2 Corin 9: 6-11, 1 Corin 16:2",
                      style: TextStyle(
                        // fontSize: 17,

                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ClipRRect(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    // padding: EdgeInsets.symmetric(
                    //     horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        // color: Colors.red,
                        gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              // Color(0xffFF0000),
                              Color(0xffEE005F),
                              Color(0xffB62A8F),
                              Color(0xff6D4B9A),
                              Color(0xff325082),
                              Color(0xff2F4858),
                              // Color(0xff845EC2),
                              // Color(0xffD65DB1),
                              // Color(0xffFF6F91),
                              // Color(0xffFF9671),
                              // Color(0xffFF9671),
                              // Color(0xffFFC75F),
                              // Color(0xffF9F871),
                              // Color(0xff),
                            ]),
                        // image: DecorationImage(
                        //     image: AssetImage("assets/image/bg_sky.jpg"),
                        //     fit: BoxFit.cover),
                        // color: Colors.grey[900],
                        // gradient: LinearGradient(
                        //     begin: Alignment.topLeft,
                        //     end: Alignment.bottomRight,
                        //     colors: [
                        //       Colors.grey[900]!,
                        //       Colors.grey[900]!,
                        //       Colors.grey[900]!,
                        //       Colors.white.withOpacity(0.01),
                        //       Colors.grey[900]!,
                        //       Colors.grey[900]!,
                        //       Colors.grey[900]!,
                        //     ]),
                        borderRadius: BorderRadius.circular(10)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Positioned(
                              top: -60,
                              left: -40,
                              child: Transform.rotate(
                                angle: 3.14 / 5,
                                child: Opacity(
                                  opacity: .7,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            width: 30, color: Colors.yellow)),
                                  ),
                                ),
                              )),
                          Positioned(
                              bottom: 40,
                              right: 20,
                              child: Opacity(
                                opacity: .7,
                                child: Icon(
                                  Icons.star_outline_rounded,
                                  color: Colors.yellow,
                                ),
                              )),
                          Positioned(
                              bottom: -30,
                              right: -20,
                              child: Opacity(
                                opacity: .9,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.yellow),
                                ),
                              )),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  alignment: Alignment.topRight,
                                  child: RichText(
                                    textAlign: TextAlign.end,
                                    text: TextSpan(
                                        text: 'Banque : ',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                        children: [
                                          TextSpan(
                                            text: ' UBA ',
                                            style: TextStyle(
                                              // color: Colors.red[200],
                                              // color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 19,
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  width: double.infinity,
                                  alignment: Alignment.topLeft,
                                  child: RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                        text: 'IBAN :',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                        children: [
                                          TextSpan(
                                            text:
                                                ' BJ06 7015 0150 1500 0465 1961',
                                            style: TextStyle(
                                              // color: Colors.red[200],
                                              // color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '\nCode SWIFT/BIC : ',
                                            style: TextStyle(
                                              // color: Colors.red[200],
                                              // color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                              // fontSize: 16,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' COBBBJBJ',
                                            style: TextStyle(
                                              // color: Colors.red[200],
                                              // color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              // fontSize: 18,
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: 'Intitulé du compte',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.white),
                                      children: [
                                        TextSpan(
                                          text: '\nALONOMBA BARNAD A BORIS',
                                          style: TextStyle(
                                            // color: Colors.red[200],
                                            // color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ]),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Flexible(
                        child: Divider(
                      indent: 20,
                      endIndent: 10,
                    )),
                    Text(
                      "Ou",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Flexible(
                        child: Divider(
                      indent: 10,
                      endIndent: 20,
                    )),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                  decoration: BoxDecoration(
                      color: isDark()
                          ? Colors.white.withOpacity(.4)
                          : Colors.white,
                      boxShadow: [
                        isDark()
                            ? BoxShadow()
                            : BoxShadow(
                                color: Colors.grey[300]!, blurRadius: 10)
                      ],
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: "67659797"));
                      showSimpleNotification(
                          Text("Numéro de téléphone copier avec succès ! "),
                          background: Colors.green);
                    },
                    title: Text("MTN Mobile Money"),
                    subtitle: Text(
                        "(+229) 67 65 97 97 \nCliquez pour copier le numéro"),
                    leading: Image.asset("assets/image/mtn.webp"),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                  decoration: BoxDecoration(
                      color: isDark()
                          ? Colors.white.withOpacity(.4)
                          : Colors.white,
                      boxShadow: [
                        isDark()
                            ? BoxShadow()
                            : BoxShadow(
                                color: Colors.grey[300]!, blurRadius: 10)
                      ],
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    onTap: () {
                      showDialog(
                          context: context,
                          // barrierDismissible: false,
                          builder: (context) => AlertDialog(
                                title: Text("Montant"),
                                content: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: themeData
                                          .textTheme.bodyText1!.color!
                                          .withOpacity(0.2)),
                                  child: TextField(
                                    onSubmitted: (value) {
                                      int montant =
                                          int.tryParse(value.toString()) ?? 0;
                                      if (montant <= 0) {
                                        return;
                                      }

                                      var kkiapay = KKiaPay(
                                          callback: ((p0, p1) {
                                            exitloading(context);

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  backgroundColor: Colors.green,
                                                  duration:
                                                      Duration(seconds: 5),
                                                  content: Text(
                                                    "Que Dieu vous le rende au centuple ! ",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )),
                                            );
                                          }),
                                          amount: montant,
                                          apikey: kkia_sandox
                                              ? kkia_public_key_sandox
                                              : kkia_public_key,
                                          sandbox: kkia_sandox,
                                          data: 'OFFRANDE',
                                          phone: '',
                                          name: '',
                                          theme: 'black');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => kkiapay),
                                      ).then((value) {
                                        exitloading(context);
                                      });
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ));
                    },
                    title: Text("Offrande"),
                    subtitle: Text("Carte de crédit, MoMo ..."),
                    leading: Icon(FontAwesomeIcons.creditCard),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
