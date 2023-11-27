import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailContact extends StatefulWidget {
  String categ;
  DetailContact(this.categ);

  @override
  State<DetailContact> createState() => _DetailContactState();
}

class _DetailContactState extends State<DetailContact> {
  List<Map<String, dynamic>> list_lien_cat = [{}, {}, {}];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xfffafafa),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                CupertinoIcons.xmark_circle_fill,
                color: Colors.red,
              )),
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: 'EGLISE ',
                style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'
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
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.separated(
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.grey[400]!, blurRadius: 10)
                      ],
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text("PayPal"),
                    subtitle: Text("Cliquez pour suivre le lien"),
                    leading: Icon(
                      FontAwesomeIcons.paypal,
                      color: Colors.blue[800],
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    trailing: Column(
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              FontAwesomeIcons.solidCopy,
                              color: Colors.grey[400],
                            )),
                        // Text("Copier")
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Row(
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
                );
              },
              itemCount: list_lien_cat.length),
        ));
  }
}
