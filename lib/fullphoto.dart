import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterphotometa/main.dart';
import 'package:flutterphotometa/protobuf/photo.pb.dart';
import 'package:flutterphotometa/widgets/local_image_provider.dart';
import 'package:flutterphotometa/widgets/metadata.dart';
import 'package:flutterphotometa/widgets/photoview.dart';

class FullPhoto extends StatelessWidget {
  static GlobalKey safeAreaKey = GlobalKey();

  final Photo _photo;
  final String _tag;
  final ImageProvider _codeProvider;

  FullPhoto(this._photo, this._tag, this._codeProvider) : super();

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: Text("Full Photo"));
    final localImgProvider = LocalImageProvider(_photo); 
    double initialTop;
    {
      final imageRatio = _photo.width / _photo.height;
      final viewHeight = MediaQuery.of(context).size.height - appBar.preferredSize.height - MediaQuery.of(context).padding.top;
      final viewRatio = MediaQuery.of(context).size.width / viewHeight;
      if (viewRatio > imageRatio) {
        initialTop = viewHeight;
      } else {
        final imageHeight = MediaQuery.of(context).size.width / imageRatio;
        initialTop = imageHeight + (viewHeight - imageHeight)/2;
      }
    }
    final GlobalKey key = GlobalKey();
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        key: FullPhoto.safeAreaKey,
        top: true,
        bottom: false,
        left: true,
        right: true,
        child: FullPhotoView(
          tag: _tag,
          metaKey: key,
          initTop: initialTop,
          photo: _photo,
          child: LocalImageProvider.keyExisted(_photo)
              ? Image(image: localImgProvider, fit: BoxFit.contain, width: double.infinity, height: double.infinity,)
              : FadeInImage(
                  placeholder: _codeProvider,
                  image: LocalImageProvider(_photo),
                  fadeInDuration: Duration(milliseconds: 10),
                  fadeOutDuration: Duration(milliseconds: 10),
                  width: double.infinity, height: double.infinity,
                  fit: BoxFit.contain),
          metadata: PhotoMetadataWidget(_photo, key),
        ),
      ),
    );
  }
}
