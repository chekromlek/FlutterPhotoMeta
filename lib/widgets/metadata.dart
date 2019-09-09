import 'package:flutterphotometa/main.dart';
import 'package:flutterphotometa/protobuf/intercom.pbserver.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterphotometa/protobuf/photo.pb.dart';

/**
 * 
 */
class PhotoMetadataWidget extends StatefulWidget {
  
  PhotoMetadataWidget(this._photo, this._key) : super();

  final Photo _photo;

  final GlobalKey _key;

  @override
  State<StatefulWidget> createState() {
    return _MetadataState(_photo);
  }
}

/**
 * 
 */
class _MetadataState extends State<PhotoMetadataWidget> {
  _MetadataState(this._photo) : super();

  final Photo _photo;

  Future<PhotoMetadata> _futureMetadata;

  bool hasMetadata;

  @override
  void initState() {
    super.initState();
    hasMetadata = false;
    _futureMetadata = _loadMetadata();
  }

  Future<PhotoMetadata> _loadMetadata() async {
    try {
      return MyApp.platform.invokePlatfromMethod(ValidMethod.GET_PHOTO_METADATA,
          msgDecoder: (bytes) => PhotoMetadata.fromBuffer(bytes),
          arguments: _photo);
    } catch (e) {
      throw (e);
    }
  }

  double _megapixel() {
    return ((_photo.height * _photo.width / 10485.76).ceilToDouble()) / 100;
  }

  String _fileSize(PhotoMetadata _metadata) {
    final kb = _metadata.fileSize.toDouble() / 1024;
    if (kb < 1024)
      return "${kb.round()}KB";
    else
      return "${(kb / 1024).round()}MB";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PhotoMetadata>(
        future: _futureMetadata,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return buildContent(context, snapshot.data);
          }
          // TODO: handle error, loading ...etc
          return Text("Loading!");
        });
  }

  Widget buildContent(BuildContext context, PhotoMetadata _metadata) {
    hasMetadata = (_metadata.captureAt != 0) ||
        (_metadata.make != "") ||
        (_metadata.location.latitude != 0.0) ||
        (_metadata.location.longitude != 0.0);
    return Visibility(
      visible: true,
      child: Container(
        key: widget._key,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 2, bottom: 3),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        MdiIcons.image,
                        size: 30,
                      ),
                      Spacer(),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _photo.name,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${_megapixel()}MP ・ ${_photo.width}x${_photo.height}px ・ ${_fileSize(_metadata)}",
                              textAlign: TextAlign.center,
                            )
                          ]),
                      Spacer(flex: 20),
                    ])),
            Padding(
              padding: EdgeInsets.only(top: 3, bottom: 3),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(MdiIcons.calendarToday, size: 30),
                    Spacer(),
                    Text(
                        (_metadata.captureAt == 0)
                            ? "Unknown"
                            : DateFormat("EEE, dd MMMM yyyy HH:mm aaa").format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    _metadata.captureAt.toInt())),
                        textAlign: TextAlign.center),
                    Spacer(flex: 20),
                  ]),
            ),
            Padding(
              padding: EdgeInsets.only(top: 3, bottom: 3),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      MdiIcons.mapMarker,
                      size: 30,
                    ),
                    Spacer(),
                    Text(
                        (_metadata.location.latitude == 0 &&
                                _metadata.location.longitude == 0)
                            ? "Unknown"
                            : "${_metadata.location.latitude},${_metadata.location.longitude}",
                        textAlign: TextAlign.center),
                    Spacer(flex: 20),
                  ]),
            ),
            Padding(
              padding: EdgeInsets.only(top: 3, bottom: 2),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      MdiIcons.camera,
                      size: 30,
                    ),
                    Spacer(),
                    Text((_metadata.make == "") ? "Unknown" : _metadata.make,
                        textAlign: TextAlign.center),
                    Spacer(flex: 20),
                  ]),
            ),
            Visibility(
              visible: hasMetadata,
              child: RaisedButton(
                onPressed: () async {
                  final result = await MyApp.platform.invokePlatfromMethod(
                      ValidMethod.REMOVE_PHOTO_METADATA,
                      arguments: _photo);
                  SnackBar snackBar;
                  if (result == true) {
                    snackBar =
                        SnackBar(content: Text('Metadata has been removed.'));
                    setState(() {
                      hasMetadata = false;
                      _futureMetadata = _loadMetadata();
                    });
                  } else {
                    snackBar =
                        SnackBar(content: Text('Failed to remove metadata.'));
                  }
                  Scaffold.of(context).showSnackBar(snackBar);
                },
                child: Text("Remove metadata"),
              ),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
      ),
    );
  }
}
