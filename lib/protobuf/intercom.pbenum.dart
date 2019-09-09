///
//  Generated code. Do not modify.
//  source: intercom.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' as $core show int, dynamic, String, List, Map;
import 'package:protobuf/protobuf.dart' as $pb;

class ValidMethod extends $pb.ProtobufEnum {
  static const ValidMethod UNKNOWN = ValidMethod._(0, 'UNKNOWN');
  static const ValidMethod GET_PHOTO = ValidMethod._(1, 'GET_PHOTO');
  static const ValidMethod LIST_PHOTOS = ValidMethod._(3, 'LIST_PHOTOS');
  static const ValidMethod GET_PHOTO_METADATA = ValidMethod._(4, 'GET_PHOTO_METADATA');
  static const ValidMethod REMOVE_PHOTO_METADATA = ValidMethod._(5, 'REMOVE_PHOTO_METADATA');

  static const $core.List<ValidMethod> values = <ValidMethod> [
    UNKNOWN,
    GET_PHOTO,
    LIST_PHOTOS,
    GET_PHOTO_METADATA,
    REMOVE_PHOTO_METADATA,
  ];

  static final $core.Map<$core.int, ValidMethod> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ValidMethod valueOf($core.int value) => _byValue[value];

  const ValidMethod._($core.int v, $core.String n) : super(v, n);
}

class DataType extends $pb.ProtobufEnum {
  static const DataType NULL = DataType._(0, 'NULL');
  static const DataType BOOL = DataType._(1, 'BOOL');
  static const DataType INT32 = DataType._(2, 'INT32');
  static const DataType INT64 = DataType._(3, 'INT64');
  static const DataType FLOAT64 = DataType._(4, 'FLOAT64');
  static const DataType STRING = DataType._(5, 'STRING');
  static const DataType UINT8LIST = DataType._(6, 'UINT8LIST');
  static const DataType INT32LIST = DataType._(7, 'INT32LIST');
  static const DataType INT64LIST = DataType._(8, 'INT64LIST');
  static const DataType FLOAT32LIST = DataType._(9, 'FLOAT32LIST');
  static const DataType FLOAT64LIST = DataType._(10, 'FLOAT64LIST');
  static const DataType LIST = DataType._(11, 'LIST');
  static const DataType MAP = DataType._(12, 'MAP');
  static const DataType MESSAGE = DataType._(13, 'MESSAGE');

  static const $core.List<DataType> values = <DataType> [
    NULL,
    BOOL,
    INT32,
    INT64,
    FLOAT64,
    STRING,
    UINT8LIST,
    INT32LIST,
    INT64LIST,
    FLOAT32LIST,
    FLOAT64LIST,
    LIST,
    MAP,
    MESSAGE,
  ];

  static final $core.Map<$core.int, DataType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static DataType valueOf($core.int value) => _byValue[value];

  const DataType._($core.int v, $core.String n) : super(v, n);
}

