

import 'package:flutter/material.dart';
import 'package:flutterphotometa/protobuf/photo.pb.dart';

Rect computeDesitnationBound(Photo photo, GlobalKey refArea) {
  final RenderBox renderObj = refArea.currentContext.findRenderObject();
    final area = renderObj.size;
    final imageRatio = photo.width / photo.height;
    final areaRation = area.width / area.height;
    final touchSide = imageRatio > areaRation;

    Rect rect;
    final minTop = MediaQuery.of(refArea.currentContext).size.height - area.height;
    if (touchSide) {
      final height = area.width / imageRatio;
      final top = minTop + (area.height - height) / 2;
      rect = Rect.fromLTWH(0, top, area.width, height);
    } else {
      final width = area.height * imageRatio;
      final left = (area.width - width) / 2;
      rect = Rect.fromLTWH(left, minTop, width, area.height);
    }
    return rect;
}