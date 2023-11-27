import 'package:eglise_de_ville/api_operation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../contantes.dart';

class CarouselAccuel extends StatefulWidget {
  @override
  State<CarouselAccuel> createState() => _CarouselAccuelState();
}

class _CarouselAccuelState extends State<CarouselAccuel> {
  int photoIndex = 0;
  bool isload = false;
  List<String> photos = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargement();
  }

  void chargement() async {
    var t = await select_data("SELECT * from Gallery_Carousel ");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      t.forEach((element) {
        if (mounted)
          setState(() {
            photos.add(element["Lien"].toString());
          });
      });
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      // showMessage("Erreur", t[0]["error"].toString(), context);
    }
  }

  void _previousImage() {
    setState(() {
      photoIndex = photoIndex > 0 ? photoIndex - 1 : 0;
    });
  }

  void _nextImage() {
    setState(() {
      photoIndex = photoIndex < photos.length - 1 ? photoIndex + 1 : photoIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return photos.length == 0
        ? SizedBox()
        : Container(
            height: (MediaQuery.of(context).size.height * .2),
            width: double.infinity,
            child: CarouselSlider(
              items: [for (var item in photos) get_cached_image(item)],
              carouselController: CarouselController(),
              options: CarouselOptions(
                autoPlay: false,
                enlargeCenterPage: true,
                viewportFraction: 1,
                aspectRatio: 2.0,
                initialPage: 0,
                // autoPlayAnimationDuration: Duration(seconds: 5)
              ),
            ),
          );
  }
}

class SelectedPhoto extends StatelessWidget {
  final int numberOfDots;
  final int photoIndex;

  SelectedPhoto({required this.numberOfDots, required this.photoIndex});

  Widget _inactivePhoto() {
    return new Container(
        child: new Padding(
      padding: const EdgeInsets.only(left: 3.0, right: 3.0),
      child: Container(
        height: 8.0,
        width: 8.0,
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(4.0)),
      ),
    ));
  }

  Widget _activePhoto() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 3.0, right: 3.0),
        child: Container(
          height: 10.0,
          width: 10.0,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey, spreadRadius: 0.0, blurRadius: 2.0)
              ]),
        ),
      ),
    );
  }

  List<Widget> _buildDots() {
    List<Widget> dots = [];

    for (int i = 0; i < numberOfDots; ++i) {
      dots.add(i == photoIndex ? _activePhoto() : _inactivePhoto());
    }

    return dots;
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildDots(),
      ),
    );
  }
}
