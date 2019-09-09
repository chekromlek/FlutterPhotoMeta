

import 'package:flutter/services.dart';
import 'package:flutterphotometa/protobuf/intercom.pbenum.dart';
import 'package:flutterphotometa/protobuf/intercom.pbserver.dart';

class CustomMethodCall extends MethodCall {

  final ValidMethod platformMethod;
  final dynamic arguments;

  const CustomMethodCall(this.platformMethod, this.arguments): super("");

  @override
  String toString() => '$runtimeType(${platformMethod.toString()}, ${arguments.toString()})';

}