import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/config.dart';

class CommingSoon extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  CommingSoon(this.zoomDrawerController);

  @override
  State<CommingSoon> createState() => _CommingSoonState();
}

class _CommingSoonState extends State<CommingSoon> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.bell_fill,
                color: Colors.grey[800],
              ))
        ],
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: 'EGLISE ',
              style: TextStyle(
                color: Colors.black45,

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
      body: Center(
        child: Text("Coming Soon"),
      ),
    );
  }
}
