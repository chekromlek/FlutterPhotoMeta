import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dcache/dcache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterphotometa/main.dart';
import 'package:flutterphotometa/protobuf/intercom.pbenum.dart';
import 'package:flutterphotometa/protobuf/photo.pbserver.dart';

class _CodecImageProvider extends ImageProvider<_CodecImageProvider> {
  _CodecImageProvider(this.codec);

  ui.Codec codec;

  @override
  ImageStreamCompleter load(_CodecImageProvider key) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: 100.0,
    );
    ;
  }

  @override
  Future<_CodecImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_CodecImageProvider>(this);
  }

  Future<ui.Codec> _loadAsync(_CodecImageProvider key) async {
    return Future.value(codec);
  }
}

class LocalImageProvider extends ImageProvider<LocalImageProvider> {
  static final Cache cache = new SimpleCache(storage: SimpleStorage(size: 15));

  static ImageProvider loadImage(Photo photo, {int width = 0, int height = 0}) {
    final codec = cache.get(_key(photo.localIdentifier, width, height));
    if (codec != null) {
      return _CodecImageProvider(codec);
    } else {
      return LocalImageProvider(photo, width: width, height: height);
    }
  }

  static ImageProvider cacheOrPlaceholder(String asset, Photo photo, {int width = 0, int height = 0}) {
    final codec = cache.get(_key(photo.localIdentifier, width, height));
    if (codec != null) {
      return _CodecImageProvider(codec);
    } else {
      return AssetImage(asset);
    }
  }

  static bool keyExisted(Photo photo, {int width = 0, int height = 0}) {
    return cache.containsKey(_key(photo.localIdentifier, width, height));
  }

  static String _key(String iden, int width, int height) {
    return "$iden:$width:$height";
  }

  LocalImageProvider(this.photo, {this.width = 0, this.height = 0});

  Photo photo;

  int width;

  int height;

  @override
  ImageStreamCompleter load(LocalImageProvider key) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents),
      chunkEvents: chunkEvents.stream,
      scale: 100.0,
    );
  }

  @override
  Future<LocalImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<LocalImageProvider>(this);
  }

  Future<ui.Codec> _loadAsync(LocalImageProvider key,
      StreamController<ImageChunkEvent> chunkEvents) async {
    try {
      final String key = _key(photo.localIdentifier, width, height);
      ui.Codec codec = cache.get(key);
      if (codec == null) {
        final bytes = await () async {
          final photo = this.photo.clone();
          photo.width = width;
          photo.height = height;
          return MyApp.platform
              .invokePlatfromMethod(ValidMethod.GET_PHOTO, arguments: photo);
        }();

        return PaintingBinding.instance
            .instantiateImageCodec(bytes)
            .then((inCodec) {
          cache.set(key, inCodec);
          return inCodec;
        });
      } else {
        return Future.value(codec);
      }
    } finally {
      chunkEvents.close();
    }
  }
}
