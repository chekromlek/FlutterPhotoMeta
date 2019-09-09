///
//  Generated code. Do not modify.
//  source: photo.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core show bool, Deprecated, double, int, List, Map, override, pragma, String;

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

class Photo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Photo')
    ..aOS(1, 'name')
    ..a<$core.int>(2, 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(3, 'height', $pb.PbFieldType.O3)
    ..aOS(4, 'localIdentifier')
    ..aInt64(5, 'fileSize')
    ..hasRequiredFields = false
  ;

  Photo._() : super();
  factory Photo() => create();
  factory Photo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Photo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Photo clone() => Photo()..mergeFromMessage(this);
  Photo copyWith(void Function(Photo) updates) => super.copyWith((message) => updates(message as Photo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Photo create() => Photo._();
  Photo createEmptyInstance() => create();
  static $pb.PbList<Photo> createRepeated() => $pb.PbList<Photo>();
  static Photo getDefault() => _defaultInstance ??= create()..freeze();
  static Photo _defaultInstance;

  $core.String get name => $_getS(0, '');
  set name($core.String v) { $_setString(0, v); }
  $core.bool hasName() => $_has(0);
  void clearName() => clearField(1);

  $core.int get width => $_get(1, 0);
  set width($core.int v) { $_setSignedInt32(1, v); }
  $core.bool hasWidth() => $_has(1);
  void clearWidth() => clearField(2);

  $core.int get height => $_get(2, 0);
  set height($core.int v) { $_setSignedInt32(2, v); }
  $core.bool hasHeight() => $_has(2);
  void clearHeight() => clearField(3);

  $core.String get localIdentifier => $_getS(3, '');
  set localIdentifier($core.String v) { $_setString(3, v); }
  $core.bool hasLocalIdentifier() => $_has(3);
  void clearLocalIdentifier() => clearField(4);

  Int64 get fileSize => $_getI64(4);
  set fileSize(Int64 v) { $_setInt64(4, v); }
  $core.bool hasFileSize() => $_has(4);
  void clearFileSize() => clearField(5);
}

class Photos extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Photos')
    ..pc<Photo>(1, 'photos', $pb.PbFieldType.PM,Photo.create)
    ..hasRequiredFields = false
  ;

  Photos._() : super();
  factory Photos() => create();
  factory Photos.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Photos.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Photos clone() => Photos()..mergeFromMessage(this);
  Photos copyWith(void Function(Photos) updates) => super.copyWith((message) => updates(message as Photos));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Photos create() => Photos._();
  Photos createEmptyInstance() => create();
  static $pb.PbList<Photos> createRepeated() => $pb.PbList<Photos>();
  static Photos getDefault() => _defaultInstance ??= create()..freeze();
  static Photos _defaultInstance;

  $core.List<Photo> get photos => $_getList(0);
}

class Location extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Location')
    ..a<$core.double>(1, 'latitude', $pb.PbFieldType.OD)
    ..a<$core.double>(2, 'longitude', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  Location._() : super();
  factory Location() => create();
  factory Location.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Location.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Location clone() => Location()..mergeFromMessage(this);
  Location copyWith(void Function(Location) updates) => super.copyWith((message) => updates(message as Location));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Location create() => Location._();
  Location createEmptyInstance() => create();
  static $pb.PbList<Location> createRepeated() => $pb.PbList<Location>();
  static Location getDefault() => _defaultInstance ??= create()..freeze();
  static Location _defaultInstance;

  $core.double get latitude => $_getN(0);
  set latitude($core.double v) { $_setDouble(0, v); }
  $core.bool hasLatitude() => $_has(0);
  void clearLatitude() => clearField(1);

  $core.double get longitude => $_getN(1);
  set longitude($core.double v) { $_setDouble(1, v); }
  $core.bool hasLongitude() => $_has(1);
  void clearLongitude() => clearField(2);
}

class PhotoMetadata extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PhotoMetadata')
    ..aInt64(1, 'captureAt')
    ..a<Location>(2, 'location', $pb.PbFieldType.OM, Location.getDefault, Location.create)
    ..aOS(3, 'make')
    ..aInt64(5, 'fileSize')
    ..hasRequiredFields = false
  ;

  PhotoMetadata._() : super();
  factory PhotoMetadata() => create();
  factory PhotoMetadata.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PhotoMetadata.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  PhotoMetadata clone() => PhotoMetadata()..mergeFromMessage(this);
  PhotoMetadata copyWith(void Function(PhotoMetadata) updates) => super.copyWith((message) => updates(message as PhotoMetadata));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PhotoMetadata create() => PhotoMetadata._();
  PhotoMetadata createEmptyInstance() => create();
  static $pb.PbList<PhotoMetadata> createRepeated() => $pb.PbList<PhotoMetadata>();
  static PhotoMetadata getDefault() => _defaultInstance ??= create()..freeze();
  static PhotoMetadata _defaultInstance;

  Int64 get captureAt => $_getI64(0);
  set captureAt(Int64 v) { $_setInt64(0, v); }
  $core.bool hasCaptureAt() => $_has(0);
  void clearCaptureAt() => clearField(1);

  Location get location => $_getN(1);
  set location(Location v) { setField(2, v); }
  $core.bool hasLocation() => $_has(1);
  void clearLocation() => clearField(2);

  $core.String get make => $_getS(2, '');
  set make($core.String v) { $_setString(2, v); }
  $core.bool hasMake() => $_has(2);
  void clearMake() => clearField(3);

  Int64 get fileSize => $_getI64(3);
  set fileSize(Int64 v) { $_setInt64(3, v); }
  $core.bool hasFileSize() => $_has(3);
  void clearFileSize() => clearField(5);
}

