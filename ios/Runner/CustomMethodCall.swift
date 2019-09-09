//
//  CustomMethodCall.swift
//  Runner
//
//  Created by Veasna Sreng on 8/21/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Flutter
import SwiftProtobuf

class CustomMethodCall<T>: FlutterMethodCall {
    
    var platformMethod: ValidMethod
    var args: T?
    
    init(method aValidMethod: ValidMethod, args: T?) {
        self.platformMethod = aValidMethod
        self.args = args
    }
    
    func invokeMethod(result: @escaping FlutterResult) {
        Plugins.sharedInstance().Invoke(identifier: platformMethod, arg: args, result: result)
    }
    
}
