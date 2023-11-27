import 'dart:ui';

import 'package:eglise_de_ville/api_operation.dart';
import 'package:eglise_de_ville/contante_var2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:shimmer/shimmer.dart';
import '../contantes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class GalleryPhoto extends StatefulWidget {
  ZoomDrawerController zoomDrawerController;
  GalleryPhoto(this.zoomDrawerController);

  @override
  State<GalleryPhoto> createState() => _GalleryPhotoState();
}

class _GalleryPhotoState extends State<GalleryPhoto> {
  bool isload = false;
  List<Map<String, dynamic>> list_image = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargement();
  }

  void chargement() async {
    setState(() {
      isload = true;
      list_image = [];
    });
    var t = await select_data("SELECT * from Gallery ");

    if (t != null && t.isNotEmpty && !t[0].containsKey("error")) {
      setState(() {
        list_image = t;
      });
    } else if (t != null && t.isNotEmpty && t[0].containsKey("error")) {
      showMessage("Erreur", t[0]["error"].toString(), context);
    }
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
          elevation: 2,
          centerTitle: true,
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
        body: isload
            ? Center(child: CupertinoActivityIndicator())
            : Container(
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: StaggeredGrid.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      for (var i = 0; i < list_image.length; i++)
                        StaggeredGridTile.count(
                          crossAxisCellCount: 2,
                          mainAxisCellCount:
                              (i == 0 || i == list_image.length - 1) ? 2 : 3,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DetailPhoto(list_image[i])));
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              alignment: Alignment.center,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: get_cached_image(
                                      list_image[i]["Lien"].toString())),
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

class DetailPhoto extends StatefulWidget {
  Map<String, dynamic> map;
  DetailPhoto(this.map);

  @override
  State<DetailPhoto> createState() => _DetailPhotoState();
}

class _DetailPhotoState extends State<DetailPhoto> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Color(0xff282828),
          appBar: AppBar(
            backgroundColor: Colors.black38,
            elevation: 0,
            centerTitle: true,
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
                  style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'
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
              child: CachedNetworkImage(
                imageUrl: widget.map["Lien"].toString(),
                // width: double.infinity,
                // height: double.infinity,
                filterQuality: FilterQuality.high,
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => PhotoView(
                  imageProvider: imageProvider,
                ),
                progressIndicatorBuilder:
                    (context, chaine, DownloadProgress loadingProgress) {
                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Container(
                      color: Colors.grey[200],
                      child: Shimmer.fromColors(
                        baseColor: Colors.red,
                        highlightColor: Colors.white.withOpacity(0.5),
                        child: Center(
                          child: loadingProgress == null
                              ? CircularProgressIndicator()
                              : CircularProgressIndicator(
                                  value: loadingProgress.progress),
                        ),
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) => Icon(Icons.error),
              ))),
    );
  }
}
