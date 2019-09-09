import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutterphotometa/APIs/CustomMethodCall.dart';
import 'package:flutterphotometa/APIs/CustomMethodCodec.dart';
import 'package:flutterphotometa/protobuf/intercom.pbenum.dart';

/**
 * 
 */
typedef dynamic MessageDecoder(Uint8List byteData);

/**
 * 
 */
dynamic emptyMessageDecoder(Uint8List byteData) {
  return null;
}

/**
 * 
 */
class CustomMethodChannel extends MethodChannel {
  static const MessageDecoder emptyMsgDecoder = emptyMessageDecoder;

  const CustomMethodChannel(String name)
      : super(name, const CustomMethodCodec());

  Future<T> invokePlatfromMethod<T>(ValidMethod method,
      {MessageDecoder msgDecoder = CustomMethodChannel.emptyMsgDecoder,
      dynamic arguments}) async {
    assert(method != null);
    final ByteData result = await binaryMessenger.send(
      name,
      codec.encodeMethodCall(CustomMethodCall(method, arguments)),
    );
    if (result == null) {
      throw MissingPluginException(
          'No implementation found for method $method on channel $name');
    }
    final dynamic typedResult =
        (codec as CustomMethodCodec).decodeEnvelope(result);
    return msgDecoder != emptyMsgDecoder
        ? msgDecoder(typedResult as Uint8List)
        : typedResult as T;
  }
}
