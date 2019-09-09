import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutterphotometa/fullphoto.dart';
import 'package:flutterphotometa/main.dart';
import 'package:flutterphotometa/protobuf/photo.pbserver.dart';
import 'package:flutterphotometa/widgets/hero.dart';
import 'package:flutterphotometa/widgets/local_image_provider.dart';

class PhotoCell extends StatelessWidget {
  final Photo _photo;
  final int _index;
  final String _tag;
  BuildContext _context;

  PhotoCell(this._photo, this._index)
      : _tag = "photo-$_index",
        super();

  Tween<Rect> heroRect(Rect begin, Rect end) {
    return RectTween(begin: computeDesitnationBound(_photo, MyHomePage.safeAreaKey), end: end);
  }

  @override
  Widget build(BuildContext context) {
    this._context = context;
    final size = MediaQuery.of(context).size.width / 3;
    final localImgProvider =
        LocalImageProvider(_photo, width: size.toInt(), height: size.toInt());
    return Hero(
      tag: _tag,
      createRectTween: heroRect,
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FullPhoto(
                    _photo,
                    _tag,
                    LocalImageProvider.loadImage(_photo,
                        width: size.toInt(), height: size.toInt())))),
        child: LocalImageProvider.keyExisted(_photo,
                width: size.toInt(), height: size.toInt())
            ? Image(
                image: localImgProvider,
                fit: BoxFit.cover,
                width: size,
                height: size,
              )
            : FadeInImage(
                placeholder: LocalImageProvider.cacheOrPlaceholder(
                    "icons/imageholder.png", _photo,
                    width: size.toInt(), height: size.toInt()),
                image: localImgProvider,
                fit: BoxFit.cover,
                width: size,
                height: size,
              ),
      ),
    );
  }
}

class Int32 {}
