import 'dart:typed_data';

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer, required;
import 'package:flutter/services.dart';
import 'package:flutterphotometa/APIs/BufferReaderWriter.dart';
import 'package:flutterphotometa/APIs/CustomMethodCall.dart';

class CustomMessageCodec implements MessageCodec<dynamic> {
  const CustomMessageCodec();

  @override
  decodeMessage(ByteData message) {
    if (message == null) return null;
    final ReadBuffer buffer = ReadBuffer(message);
    final dynamic result = BufferReaderWriter().readValue(buffer);
    if (buffer.hasRemaining) throw const FormatException('Message corrupted');
    return result;
  }

  @override
  ByteData encodeMessage(message) {
    if (message == null) return null;
    final WriteBuffer buffer = WriteBuffer();
    BufferReaderWriter().writeValue(buffer, message);
    return buffer.done();
  }
}

class CustomMethodCodec implements MethodCodec {
  const CustomMethodCodec([this.messageCodec = const CustomMessageCodec()]);

  final CustomMessageCodec messageCodec;

  @override
  dynamic decodeEnvelope(ByteData envelope) {
    // First byte is zero in success case, and non-zero otherwise.
    if (envelope.lengthInBytes == 0)
      throw const FormatException('Expected envelope, got nothing');
    final ReadBuffer buffer = ReadBuffer(envelope);
    // 0 mean none error result
    if (buffer.getUint8() == 0) {
      // normal standard data being sent, see here https://flutter.dev/docs/development/platform-integration/platform-channels
      return BufferReaderWriter().readValue(buffer);
    }
    // 1 error result
    final dynamic errorCode = BufferReaderWriter().readValue(buffer);
    final dynamic errorMessage = BufferReaderWriter().readValue(buffer);
    final dynamic errorDetails = BufferReaderWriter().readValue(buffer);
    if (errorCode is String &&
        (errorMessage == null || errorMessage is String) &&
        !buffer.hasRemaining)
      throw PlatformException(
          code: errorCode, message: errorMessage, details: errorDetails);
    else
      throw const FormatException('Invalid envelope');
  }

  @override
  MethodCall decodeMethodCall(ByteData methodCall) {
    final ReadBuffer buffer = ReadBuffer(methodCall);
    final dynamic method = BufferReaderWriter().readValue(buffer);
    final dynamic arguments = BufferReaderWriter().readValue(buffer);
    if (method is String && !buffer.hasRemaining)
      return MethodCall(method, arguments);
    else
      throw const FormatException('Invalid method call');
  }

  @override
  ByteData encodeErrorEnvelope(
      {@required String code, String message, details}) {
    final WriteBuffer buffer = WriteBuffer();
    buffer.putUint8(1);
    BufferReaderWriter().writeValue(buffer, code);
    BufferReaderWriter().writeValue(buffer, message);
    BufferReaderWriter().writeValue(buffer, details);
    return buffer.done();
  }

  @override
  ByteData encodeMethodCall(MethodCall methodCall) {
    if (methodCall.runtimeType == CustomMethodCall) {
      final CustomMethodCall cmc = methodCall as CustomMethodCall;
      final WriteBuffer buffer = WriteBuffer();
      buffer.putUint8(0);
      BufferReaderWriter().writeValue(buffer, cmc.platformMethod.value);
      BufferReaderWriter().writeValue(buffer, cmc.arguments);
      return buffer.done();
    } else {
      final WriteBuffer buffer = WriteBuffer();
      buffer.putUint8(1);
      BufferReaderWriter().writeValue(buffer, methodCall.method);
      BufferReaderWriter().writeValue(buffer, methodCall.arguments);
      return buffer.done();
    }
  }

  @override
  ByteData encodeSuccessEnvelope(result) {
    final WriteBuffer buffer = WriteBuffer();
    buffer.putUint8(0);
    BufferReaderWriter().writeValue(buffer, result);
    return buffer.done();
  }
}
