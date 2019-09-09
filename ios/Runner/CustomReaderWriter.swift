//
//  CustomReaderWriter.swift
//  Runner
//
//  Created by Veasna Sreng on 8/26/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import SwiftProtobuf


/**
 `ValueWrapper` a wrapper class to carry the generic type of any at runtime. As result pass to Flutter Objective C
 the return id does not include swift type meta causing type check to failed. In order to preserve the type check the value need
 to wrapped inside ValueWrapper and cast the value to use before writing value to the buffer.
 
 Note: The value pass from Objective C did not include swift type meta however it can be cast directly to certain.
 */
class ValueWrapper {
    var val: Any?
    init(_ v: Any?) {
        self.val = v
    }
}

/**
 `BufferWritter` a writer that convert the input value into binary array.
 */
protocol BufferWritter {
    @discardableResult func writeByte(b: UInt8) -> Self
    @discardableResult func writeBytes(bytes: [UInt8]) -> Self
    @discardableResult func writeData(data: Data) -> Self
    @discardableResult func writeUTF8(text: String) -> Self
    @discardableResult func write(value: Any?) -> Self
    func done() -> [UInt8]
    func seal() -> Data
}

/**
 `BufferReader` a reader that read the binary data and return the propriate value.
 */
protocol BufferReader {
    func hasMore() -> Bool
    func readByte() -> UInt8
    func readBytes() -> [UInt8]
    func readData() -> Data
    func readUTF8() -> String
    func readValue<T>() -> T?
}

/// A message type identifier which indicate that the binary data is a protobuf binary encoded.
class MessageIdentifier {}

/// A dictionary type identifier which indicate that the binary data is the encoded dictionary of type <AnyHashable:Any>
class MapIdentifier {}

/// A list or array type identifier which indicate that the binary data is the encoded array of type <Any>
class ListIdentifier {}

/// internal typealias that use for quick mapping between input value and the function that convert the input value into binary data.
typealias TypeWriter = (ReaderWriter, Any) -> ()

/// internal typealias that use for quick mapping between binary data type and the function that convert the binary input into actual data type.
typealias TypeReader = (ReaderWriter) -> Any?

/**
 `ReaderWriter` a helper class that implement BufferWriter and BufferReader.
 */
class ReaderWriter {
    
    /**
     `writer` create a new instance of `BufferWriter`
     - Parameter capacity: the initial size of buffer data when create. By default, the capacity is set to 32 bytes.
     - Returns: a buffer writter instance
     */
    static func writer(capacity size: Int = 32) -> BufferWritter  {
        return ReaderWriter(with: Data())
    }
    
    /**
     `reader` create a new instance of `BufferReader`
     - Parameter with: a `Data` object that hold binary data format written by `BufferWritter` or Dart Plugins
     - Returns: a buffer reader instance
     */
    static func reader(with aData: Data) -> BufferReader {
        return ReaderWriter(with: aData);
    }
    
    /// a buffer data
    private var data: Data?
    
    private init(with aData: Data) {
        self.data = aData
    }
    
    /// ObjectIdentifier key to mapping message type and function for encode and decode binary data.
    private static let messageIdentifier = ObjectIdentifier(MessageIdentifier.self)
    /// ObjectIdentifier key to mapping dictionary and function for encode and decode binary data.
    private static let mapIdentifier = ObjectIdentifier(MapIdentifier.self)
    /// ObjectIdentifier key to mapping array and function for encode and decode binary data.
    private static let listIdentifier = ObjectIdentifier(ListIdentifier.self)
    
    /// map of binary encodeing function and it own typed.
    private static let typeWriter: [ ObjectIdentifier: TypeWriter ] = [
        ObjectIdentifier(type(of: true)): { (writer: ReaderWriter, val: Any) in
            writer.data!.append(UInt8(DataType.bool.rawValue))
            let bool = val as! Bool
            writer.data!.append(bool ? 1 : 0)
        },
        ObjectIdentifier(type(of: 1)): { (writer: ReaderWriter, val: Any) in
            let intVal = val as! Int
            if (-0x7fffffff - 1 <= intVal && intVal <= 0x7fffffff) {
                writer.data!.append(UInt8(DataType.int32.rawValue))
                writer.data!.append(contentsOf: withUnsafeBytes(of: intVal) { val in
                    return [UInt8](val[0..<4])
                })
            } else {
                writer.data!.append(UInt8(DataType.int64.rawValue))
                writer.data!.append(contentsOf: withUnsafeBytes(of: intVal) { val in
                    return [UInt8](val[0..<8])
                })
            }
        },
        ObjectIdentifier(type(of: Float(1.0))): { (writer: ReaderWriter, val: Any) in
            writer.data!.append(UInt8(DataType.float64.rawValue))
            writer.data!.append(contentsOf: withUnsafeBytes(of: Double(exactly: (val as! Float))) { val in
                return [UInt8](val[0..<8])
            })
        },
        ObjectIdentifier(type(of: Double(1.0))): { (writer: ReaderWriter, val: Any) in
            writer.data!.append(UInt8(DataType.float64.rawValue))
            writer.data!.append(contentsOf: withUnsafeBytes(of: val as! Double) { val in
                return [UInt8](val[0..<8])
            })
        },
        ObjectIdentifier(type(of: "")): { (writer: ReaderWriter, val: Any) in
            let str = val as! String
            writer.data!.append(UInt8(DataType.string.rawValue))
            ReaderWriter.writeSize(data: &writer.data!, size: UInt32(str.utf8.count))
            writer.data!.append(contentsOf: str.utf8)
        },
        ObjectIdentifier(type(of: [UInt8(1)])): { (writer: ReaderWriter, val: Any) in
            let arr = val as! [UInt8]
            writer.data!.append(UInt8(DataType.uint8List.rawValue))
            ReaderWriter.writeSize(data: &writer.data!, size: UInt32(arr.count))
            writer.data!.append(contentsOf: arr)
        },
        ObjectIdentifier(type(of: [Int32(1)])): { (writer: ReaderWriter, val: Any) in
            let arrInt = val as! [Int32]
            let bytes = arrInt.withUnsafeBytes { val in
                return [UInt8](val)
            }
            writer.data!.append(UInt8(DataType.int32List.rawValue))
            ReaderWriter.writeSize(data: &writer.data!, size: UInt32(bytes.count))
            writer.data!.append(contentsOf: bytes)
        },
        ObjectIdentifier(type(of: [Int64(1)])): { (writer: ReaderWriter, val: Any) in
            let arrInt = val as! [Int64]
            let bytes = arrInt.withUnsafeBytes { val in
                return [UInt8](val)
            }
            writer.data!.append(UInt8(DataType.int64List.rawValue))
            ReaderWriter.writeSize(data: &writer.data!, size: UInt32(bytes.count))
            writer.data!.append(contentsOf: bytes)
        },
        ObjectIdentifier(type(of: [Float64(1.0)])): { (writer: ReaderWriter, val: Any) in
            let arrFloat = val as! [Float64]
            let bytes = arrFloat.withUnsafeBytes { val in
                return [UInt8](val)
            }
            writer.data!.append(UInt8(DataType.float64List.rawValue))
            ReaderWriter.writeSize(data: &writer.data!, size: UInt32(bytes.count))
            writer.data!.append(contentsOf: bytes)
        },
        ReaderWriter.listIdentifier: { (writer: ReaderWriter, val: Any) in
            let arrAny = val as! Array<Any>
            writer.data!.append(UInt8(DataType.list.rawValue))
            ReaderWriter.writeSize(data: &writer.data!, size: UInt32(arrAny.count))
            for a in arrAny {
                writer.write(value: a)
            }
        },
        ReaderWriter.mapIdentifier: { (writer: ReaderWriter, val: Any) in
            let mapAny = val as! Dictionary<AnyHashable, Any>
            writer.data!.append(UInt8(DataType.map.rawValue))
            ReaderWriter.writeSize(data: &writer.data!, size: UInt32(mapAny.count))
            for (key, anyVal) in mapAny {
                writer
                    .write(value: key)
                    .write(value: anyVal)
            }
        },
        ReaderWriter.messageIdentifier: { (writer: ReaderWriter, val: Any) in
            let msg = val as! Message
            writer.data!.append(UInt8(DataType.message.rawValue))
            let data = try! msg.serializedData()
            ReaderWriter.writeSize(data: &writer.data!, size: UInt32(data.count))
            writer.data!.append(data)
        }
    ]
    
    /// mapping of decoding binary function with value data type
    private static let typeReader: [ DataType: TypeReader ] = [
        DataType.null: { (reader: ReaderWriter) -> Any? in
            return nil
        },
        DataType.bool: { (reader: ReaderWriter) -> Any? in
            defer { reader.data!.removeFirst() }
            return reader.data!.first == 1
        },
        DataType.int32: { (reader: ReaderWriter) -> Any? in
            defer { reader.data!.removeFirst(4) }
            let lowerBound = reader.data!.indices.lowerBound
            return reader.data![lowerBound..<(lowerBound+4)].withUnsafeBytes{ Int($0.baseAddress!.assumingMemoryBound(to: Int32.self).pointee) }
        },
        DataType.int64: { (reader: ReaderWriter) -> Any? in
            defer { reader.data!.removeFirst(8) }
            let lowerBound = reader.data!.indices.lowerBound
            return reader.data![lowerBound..<(lowerBound+8)].withUnsafeBytes{ Int($0.baseAddress!.assumingMemoryBound(to: Int64.self).pointee) }
        },
        DataType.float64: { (reader: ReaderWriter) -> Any? in
            defer { reader.data!.removeFirst(8) }
            let lowerBound = reader.data!.indices.lowerBound
            return reader.data![lowerBound..<(lowerBound+8)].withUnsafeBytes{ Double($0.baseAddress!.assumingMemoryBound(to: Float64.self).pointee) }
        },
        DataType.string: { (reader: ReaderWriter) -> Any? in
            let size = Int(ReaderWriter.readSize(data: &reader.data!))
            defer { reader.data!.removeFirst(size) }
            let lowerBound = reader.data!.indices.lowerBound
            return String(bytes: Array(reader.data![lowerBound..<(lowerBound+size)]), encoding: .utf8)
        },
        DataType.uint8List: { (reader: ReaderWriter) -> Any? in
            let size = Int(ReaderWriter.readSize(data: &reader.data!))
            defer { reader.data!.removeFirst(size) }
            let lowerBound = reader.data!.indices.lowerBound
            return Array(reader.data![lowerBound..<(lowerBound+size)])
        },
        DataType.int32List: { (reader: ReaderWriter) -> Any? in
            let size = Int(ReaderWriter.readSize(data: &reader.data!))
            defer { reader.data!.removeFirst(size) }
            let lowerBound = reader.data!.indices.lowerBound
            return reader.data![lowerBound..<(lowerBound+size)].withUnsafeBytes{
                return Array(UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: Int32.self), count: size/4))
            }
        },
        DataType.int64List: { (reader: ReaderWriter) -> Any? in
            let size = Int(ReaderWriter.readSize(data: &reader.data!))
            defer { reader.data!.removeFirst(size) }
            let lowerBound = reader.data!.indices.lowerBound
            return reader.data![lowerBound..<(lowerBound+size)].withUnsafeBytes{
                return Array(UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: Int64.self), count: size/8))
            }
        },
        DataType.float64List: { (reader: ReaderWriter) -> Any? in
            let size = Int(ReaderWriter.readSize(data: &reader.data!))
            defer { reader.data!.removeFirst(size) }
            let lowerBound = reader.data!.indices.lowerBound
            return reader.data![lowerBound..<(lowerBound+size)].withUnsafeBytes{
                return Array(UnsafeBufferPointer(start: $0.baseAddress!.assumingMemoryBound(to: Double.self), count: size/8))
            }
        },
        DataType.list: { (reader: ReaderWriter) -> Any? in
            let size = Int(ReaderWriter.readSize(data: &reader.data!))
            var arr:[Any?] = []
            for _ in 0..<size {
                arr.append(reader.readValue())
            }
            return arr
        },
        DataType.map: { (reader: ReaderWriter) -> Any? in
            let size = Int(ReaderWriter.readSize(data: &reader.data!))
            var dict:[AnyHashable:Any?] = [:]
            for _ in 0..<size {
                dict[reader.readValue()!] = reader.readValue()
            }
            return dict
        },
        DataType.message: { (reader: ReaderWriter) -> Any? in
            let size = Int(ReaderWriter.readSize(data: &reader.data!))
            defer { reader.data!.removeFirst(size) }
            let lowerBound = reader.data!.indices.lowerBound
            return reader.data![lowerBound..<(lowerBound+size)]
        }
    ]
}


extension ReaderWriter: BufferWritter {
    
    @discardableResult
    func writeByte(b: UInt8) -> Self {
        self.data!.append(b)
        return self
    }
    
    @discardableResult
    func writeBytes(bytes: [UInt8]) -> Self {
        ReaderWriter.writeSize(data: &self.data!, size: UInt32(bytes.count))
        self.data!.append(contentsOf: bytes)
        return self
    }
    
    @discardableResult
    func writeData(data: Data) -> Self {
        ReaderWriter.writeSize(data: &self.data!, size: UInt32(data.count))
        self.data!.append(data)
        return self
    }
    
    @discardableResult
    func writeUTF8(text: String) -> Self {
        ReaderWriter.writeSize(data: &self.data!, size: UInt32(text.utf8.count))
        self.data!.append(contentsOf: Array(text.utf8))
        return self
    }
    
    @discardableResult
    func write(value: Any?) -> Self {
        if (value == nil) {
            self.data!.append(UInt8(DataType.null.rawValue))
        } else {
            var val = value
            if let vw = value as? ValueWrapper {
                val = vw.val
            }
            
            if (val is Dictionary<AnyHashable, Any>) {
                ReaderWriter.typeWriter[ReaderWriter.mapIdentifier]!(self, val!)
            } else if (val is [UInt8] || val is [Int32] || val is [Int64] || val is [Float64]) {
                ReaderWriter.typeWriter[ObjectIdentifier(type(of: val!))]!(self, val!)
            } else if (val is Data) {
                let bytes = [UInt8](val as! Data)
                ReaderWriter.typeWriter[ObjectIdentifier(type(of: bytes))]!(self, bytes)
            } else if (val is Array<Any>) {
                ReaderWriter.typeWriter[ReaderWriter.listIdentifier]!(self, val!)
            } else if (val is SwiftProtobuf.Message) {
                ReaderWriter.typeWriter[ReaderWriter.messageIdentifier]!(self, val!)
            } else {
                if (val! is AnyHashable) {
                    val = (val as! AnyHashable).base
                }
                ReaderWriter.typeWriter[ObjectIdentifier(type(of: val!))]!(self, val!)
            }
        }
        return self
    }
    
    func done() -> [UInt8] {
        defer { self.data = nil }
        assert(self.data != nil, "buffer has been sealed")
        return [UInt8](self.data!)
    }
    
    func seal() -> Data {
        defer { self.data = nil }
        assert(self.data != nil, "buffer has been sealed")
        return self.data!
    }
    
    fileprivate static func writeSize(data: inout Data, size: UInt32) {
        data.append(contentsOf: withUnsafeBytes(of: size) { val in
            return [UInt8](val[0..<4])
        })
    }
    
}


extension ReaderWriter: BufferReader {
    func hasMore() -> Bool {
        return self.data!.count > 0
    }
    
    func readByte() -> UInt8 {
        defer { self.data!.removeFirst() }
        return self.data!.first!
    }
    
    func readBytes() -> [UInt8] {
        let size = Int(ReaderWriter.readSize(data: &self.data!))
        defer { self.data!.removeFirst(size) }
        let lowerBound = self.data!.indices.lowerBound
        return Array(([UInt8](self.data![lowerBound..<(lowerBound+size)])))
    }
    
    func readData() -> Data {
        let size = Int(ReaderWriter.readSize(data: &self.data!))
        defer { self.data!.removeFirst(size) }
        let lowerBound = self.data!.indices.lowerBound
        return self.data![lowerBound..<(lowerBound+size)]
    }
    
    func readUTF8() -> String {
        let size = Int(ReaderWriter.readSize(data: &self.data!))
        defer { self.data!.removeFirst(size) }
        return String(bytes: ([UInt8](self.data!))[0..<size], encoding: .utf8)!
    }
    
    func readValue<T>() -> T? {
        let kind = DataType(rawValue: Int(self.data!.first!))
        self.data!.removeFirst(1)
        if (T.self is ValidMethod.Type) {
            let an = (ReaderWriter.typeReader[kind!])!(self)
            return ValidMethod(rawValue: an as! Int) as? T
        } else if (kind != DataType.message || !(T.self is Message.Type)) {
            return (ReaderWriter.typeReader[kind!])!(self) as? T
        } else {
            let msg = (T.self as! Message.Type)
            return try! msg.init(serializedData: (ReaderWriter.typeReader[kind!])!(self) as! Data) as? T
        }
    }
    
    fileprivate static func readSize(data: inout Data) -> UInt32 {
        defer { data.removeFirst(4) }
        return data.withUnsafeBytes {
            $0.baseAddress!.assumingMemoryBound(to: UInt32.self).pointee
        }
    }
}
