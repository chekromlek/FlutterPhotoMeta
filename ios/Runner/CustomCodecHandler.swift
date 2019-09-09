//
//  CustomCodecHandler.swift
//  Runner
//
//  Created by Veasna Sreng on 9/1/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import SwiftProtobuf


/**
 `MethodHandler` function signature type which define the method for calling from flutter.
 - Parameter T: a generic type arguments
 */
typealias MethodHandler<T> = (T?, @escaping FlutterResult) -> ()

/**
 */
typealias MethodInvoker = (ValidMethod, BufferReader) -> FlutterMethodCall

/**
 `Plugins` a registry class to register method to be call from Flutter Code. The plugins provide custom codec as well as
 support binary encode from protobuf which enable rich communication between dart and native platform.
 */
@objc final class Plugins: NSObject {
    
    /// the method that can be call by Flutter from Dart code.
    private var registries: [ValidMethod: Any]
    
    private var methodInvoker: [ValidMethod:MethodInvoker]
    
    private var callerMapping: [FlutterMethodCall: (@escaping FlutterResult) -> ()]
    
    /// singleton instance of plugins
    private static let instance = Plugins()
    
    /**
     Get a singleton share instance of plugins
     - Returns: an instance of plugins
     */
    static func sharedInstance() -> Plugins {
        return instance
    }
    
    /// private constructor
    internal required override init() {
        self.registries = [:]
        self.methodInvoker = [:]
        self.callerMapping = [:]
    }
    
    @discardableResult
    func Register<T: Hashable>(identifier aValidMethod: ValidMethod, method: @escaping MethodHandler<T>) -> Self {
        self.registries[aValidMethod] = method
        if (self.methodInvoker[aValidMethod] == nil) {
            self.methodInvoker[aValidMethod] = { (method: ValidMethod, reader: BufferReader) -> FlutterMethodCall in
                let a: T? = reader.readValue()
                let callingMethod = CustomMethodCall(method: method, args: a)
                self.callerMapping[callingMethod] = callingMethod.invokeMethod
                return callingMethod
            }
        }
        
        return self
    }
    
    func Invoke<T>(identifier aValidMethod: ValidMethod, arg: T?, result: @escaping FlutterResult) {
        guard let method = self.registries[aValidMethod] as? MethodHandler<T> else {
            result(FlutterMethodNotImplemented)
            return
        }
        method(arg, result)
    }
    
    func HandlingMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
        guard let caller = self.callerMapping[call] else {
            result(FlutterMethodNotImplemented)
            return
        }
        self.callerMapping.removeValue(forKey: call)
        caller(result)
    }
    
}

extension Plugins: FlutterMethodCodec {
    
    func encode(_ methodCall: FlutterMethodCall) -> Data {
        return ReaderWriter.writer()
            .write(value: methodCall.method)
            .write(value: methodCall.arguments)
            .seal()
    }
    
    func decodeMethodCall(_ methodCall: Data) -> FlutterMethodCall {
        let reader = ReaderWriter.reader(with: methodCall)
        let flag = reader.readByte()
        assert(flag <= 1, "Corrupted standard method call")
        if flag == 0 {
            let val1: ValidMethod? = reader.readValue()
            assert(val1 != nil, "Corrupted standard method call")
            let result = self.methodInvoker[val1!]!(val1!, reader)
            assert(!reader.hasMore(), "Corrupted standard method call")
            return result
        } else {
            let val1: String? = reader.readValue()
            let val2: Any? = reader.readValue()
            assert(!reader.hasMore(), "Corrupted standard method call")
            return FlutterMethodCall(methodName: val1!, arguments: val2)
        }
    }
    
    func encodeSuccessEnvelope(_ result: Any?) -> Data {
        return ReaderWriter.writer().writeByte(b: 0)
            .write(value: result)
            .seal()
    }
    
    func encodeErrorEnvelope(_ error: FlutterError) -> Data {
        let writer = ReaderWriter.writer()
        return writer.writeByte(b: 1)
            .write(value: error.code)
            .write(value: error.message)
            .write(value: error.details)
            .seal()
    }
    
    func decodeEnvelope(_ envelope: Data) -> Any? {
        let reader  = ReaderWriter.reader(with: envelope)
        let flag = reader.readByte()
        assert(flag <= 1, "Corrupted standard envelope")
        
        var result: Any? = nil
        
        switch flag {
        case 0:
            result = reader.readValue()
            assert(!reader.hasMore(), "Corrupted standard envelope")
            break
            
        case 1:
            let code: String? = reader.readValue()
            let message: String? = reader.readValue()
            let detail: String? = reader.readValue()
            assert(!reader.hasMore(), "Corrupted standard envelope")
            assert(code == nil, "Invalid standard envelope")
            assert(message == nil, "Invalid standard envelope")
            result = FlutterError(code: code!, message: message, details: detail)
            break
            
        default:
            break
            
        }
        return result
    }
    
}

extension Plugins: FlutterMessageCodec {
    
    func decode(_ message: Data?) -> Any? {
        if message != nil {
            let reader = ReaderWriter.reader(with: message!)
            let value: Any? = reader.readValue()
            assert(!reader.hasMore(), "Corrupted standard message")
            return value
        }
        return nil
    }
    
    
    func encode(_ message: Any?) -> Data? {
        if message != nil {
            let writer = ReaderWriter.writer()
            return writer.write(value: message!).seal()
        }
        return nil
    }
    
}
