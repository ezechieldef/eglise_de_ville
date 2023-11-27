import 'package:flutter/material.dart';

class MyProgressBar extends StatefulWidget {
  // max percentage = 1
  double percentage;
  double height;
  double maxWidth;
  Color bgColor;
  List<Color>? colors;
  //double deviceWidth = MediaQuery.of(context).size.width;
  MyProgressBar(
      {required this.percentage,
      required this.maxWidth,
      this.height = 50,
      this.bgColor = Colors.grey,
      this.colors});

  @override
  State<MyProgressBar> createState() => _MyProgressBarState(percentage);
}

class _MyProgressBarState extends State<MyProgressBar> {
  double percentage;
  _MyProgressBarState(this.percentage);
  @override
  Widget build(BuildContext context) {
    print("van width : ${widget.maxWidth * widget.percentage}");
    return Container(
      width: widget.maxWidth,
      decoration: BoxDecoration(
          color: widget.bgColor, borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: widget.maxWidth * widget.percentage,
        height: widget.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: widget.colors == null
                    ? [Colors.blue, Colors.pink]
                    : widget.colors!)),
      ),
    );
  }
}
