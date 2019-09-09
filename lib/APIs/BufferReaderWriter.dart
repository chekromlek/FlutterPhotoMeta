import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutterphotometa/protobuf/intercom.pbserver.dart';
import 'package:protobuf/protobuf.dart';

//
typedef void Encoder(WriteBuffer buffer, dynamic value);

//
typedef dynamic Decoder(ReadBuffer buffer);

//
class ProtoMessage extends Type {}

//
class BufferReaderWriter {

  static final BufferReaderWriter _instance =
      new BufferReaderWriter._internal();

  factory BufferReaderWriter() {
    return _instance;
  }

  static final _protoMessageType = ProtoMessage().runtimeType;

  Map<Type, Encoder> _typeWriterBuffer;
  Map<int, Decoder> _typeReaderBuffer;

  BufferReaderWriter._internal() {
    _typeWriterBuffer = {
      null.runtimeType: (WriteBuffer buffer, dynamic value) {
        buffer.putUint8(DataType.NULL.value);
      },
      true.runtimeType: (WriteBuffer buffer, dynamic value) {
        buffer.putUint8(DataType.BOOL.value);
        buffer.putUint8(value ? 1 : 0);
      },
      1.runtimeType: (WriteBuffer buffer, dynamic value) {
        if (-0x7fffffff - 1 <= value && value <= 0x7fffffff) {
          buffer.putUint8(DataType.INT32.value);
          buffer.putInt32(value);
        } else {
          buffer.putUint8(DataType.INT64.value);
          buffer.putInt64(value);
        }
      },
      1.0.runtimeType: (WriteBuffer buffer, dynamic value) {
        buffer.putUint8(DataType.FLOAT64.value);
        buffer.putFloat64(value);
      },
      "".runtimeType: (WriteBuffer buffer, dynamic value) {
        buffer.putUint8(DataType.STRING.value);
        final List<int> bytes = utf8.encoder.convert(value);
        writeVariantInt(buffer, bytes.length);
        buffer.putUint8List(bytes);
      },
      Uint8List(0).runtimeType: (WriteBuffer buffer, dynamic value) {
        buffer.putUint8(DataType.UINT8LIST.value);
        writeVariantInt(buffer, value.length);
        buffer.putUint8List(value);
      },
      Int32List(0).runtimeType: (WriteBuffer buffer, dynamic value) {
        buffer.putUint8(DataType.INT32LIST.value);
        writeVariantInt(buffer, value.length);
        buffer.putInt32List(value);
      },
      Int64List(0).runtimeType: (WriteBuffer buffer, dynamic value) {
        buffer.putUint8(DataType.INT64LIST.value);
        writeVariantInt(buffer, value.length);
        buffer.putInt64List(value);
      },
      Float64List(0).runtimeType: (WriteBuffer buffer, dynamic value) {
        buffer.putUint8(DataType.FLOAT64LIST.value);
        writeVariantInt(buffer, value.length);
        buffer.putFloat64List(value);
      },
      List().runtimeType: (WriteBuffer buffer, dynamic value) {
        buffer.putUint8(DataType.LIST.value);
        writeVariantInt(buffer, value.length);
        for (final dynamic item in value) {
          writeValue(buffer, item);
        }
      },
      Map().runtimeType: (WriteBuffer buffer, dynamic value) {
        buffer.putUint8(DataType.MAP.value);
        writeVariantInt(buffer, value.length);
        value.forEach((dynamic key, dynamic value) {
          writeValue(buffer, key);
          writeValue(buffer, value);
        });
      },
      _protoMessageType: (WriteBuffer buffer, dynamic value) {
        buffer.putUint8(DataType.MESSAGE.value);
        final message = value as GeneratedMessage;
        final bytes = message.writeToBuffer();
        writeVariantInt(buffer, bytes.length);
        buffer.putUint8List(bytes);
      },
    };

    _typeReaderBuffer = {
      DataType.NULL.value: (ReadBuffer buffer) {
        return null;
      },
      DataType.BOOL.value: (ReadBuffer buffer) {
        return buffer.getUint8() == 1;
      },
      DataType.INT32.value: (ReadBuffer buffer) {
        return buffer.getInt32();
      },
      DataType.INT64.value: (ReadBuffer buffer) {
        return buffer.getInt64();
      },
      DataType.FLOAT64.value: (ReadBuffer buffer) {
        return buffer.getFloat64();
      },
      DataType.STRING.value: (ReadBuffer buffer) {
        final size = readVariantInt(buffer);
        return utf8.decoder.convert(buffer.getUint8List(size));
      },
      DataType.UINT8LIST.value: (ReadBuffer buffer) {
        final size = readVariantInt(buffer);
        return buffer.getUint8List(size);
      },
      DataType.INT32LIST.value: (ReadBuffer buffer) {
        final size = readVariantInt(buffer);
        return buffer.getInt32List(size);
      },
      DataType.INT64LIST.value: (ReadBuffer buffer) {
        final size = readVariantInt(buffer);
        return buffer.getInt64List(size);
      },
      DataType.FLOAT64LIST.value: (ReadBuffer buffer) {
        final size = readVariantInt(buffer);
        return buffer.getFloat64List(size);
      },
      DataType.LIST.value: (ReadBuffer buffer) {
        final size = readVariantInt(buffer);
        final dynamic result = List<dynamic>(size);
        for (int i = 0; i < size; i++) result[i] = readValue(buffer);
        return result;
      },
      DataType.MAP.value: (ReadBuffer buffer) {
        final size = readVariantInt(buffer);
        final dynamic result = <dynamic, dynamic>{};
        for (int i = 0; i < size; i++)
          result[readValue(buffer)] = readValue(buffer);
        return result;
      },
      DataType.MESSAGE.value: (ReadBuffer buffer) {
        return _typeReaderBuffer[DataType.UINT8LIST.value](buffer);
      }
    };
  }

  void writeVariantInt(WriteBuffer buffer, int value) {
    buffer.putUint32(value);
  }

  int readVariantInt(ReadBuffer buffer) {
    return buffer.getUint32();
  }

  void writeValue(WriteBuffer buffer, dynamic val) {
    if (val is GeneratedMessage) {
      _typeWriterBuffer[_protoMessageType](buffer, val);
    } else {
      _typeWriterBuffer[val.runtimeType](buffer, val);
    }
  }

  readValue(ReadBuffer buffer) {
    if (!buffer.hasRemaining) throw const FormatException('Message corrupted');
    final kind = buffer.getUint8();
    final Decoder decoder = _typeReaderBuffer[kind];
    if (decoder == null) {
      throw const FormatException("Invalid message format");
    }
    return decoder(buffer);
  }
}
