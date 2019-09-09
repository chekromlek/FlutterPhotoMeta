import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutterphotometa/main.dart';
import 'package:flutterphotometa/protobuf/intercom.pbserver.dart';
import 'package:flutterphotometa/protobuf/photo.pbserver.dart';
import 'package:flutterphotometa/widgets/photocell.dart';

class PhotoView extends StatefulWidget {
  const PhotoView() : super();

  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  Future<Photos> _listPhotos;
  GridView _gridView;

  @override
  void initState() {
    super.initState();
    _listPhotos = _getListPhotoFromPlatform();
  }

  Future<Photos> _getListPhotoFromPlatform() async {
    try {
      return await MyApp.platform.invokePlatfromMethod(ValidMethod.LIST_PHOTOS,
          msgDecoder: (bd) => Photos.fromBuffer(bd));
    } catch (e) {
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Photos>(
      future: this._listPhotos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          if (_gridView == null) {
            _gridView = GridView.builder(
              itemCount: snapshot.data.photos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 1.5,
                mainAxisSpacing: 1.5,
              ),
              itemBuilder: (BuildContext ctx, int index) {
                return PhotoCell(snapshot.data.photos[index], index);
              },
            );
          }
          return _gridView;
        } else {
          return Text("Error");
        }
      },
    );
  }
}
