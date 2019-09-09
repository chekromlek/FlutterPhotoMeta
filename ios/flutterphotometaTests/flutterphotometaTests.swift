//
//  flutterphotometaTests.swift
//  flutterphotometaTests
//
//  Created by Veasna Sreng on 8/27/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import XCTest

@testable import Runner

class flutterphotometaTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.continueAfterFailure = false
    }
    
    func testWriteByte() {
        let writer = ReaderWriter.writer()
        let data = writer.writeByte(b: 2).done()
        XCTAssertEqual(data.count, 1)
        XCTAssertEqual(data[0], 2)
    }
    
    func testReadByte() {
        let writer = ReaderWriter.writer()
        let reader = ReaderWriter.reader(with: Data(writer.writeByte(b: 2).done()))
        XCTAssertEqual(reader.readByte(), 2)
        XCTAssert(!reader.hasMore())
    }
    
    func testWriteBytes() {
        let writer = ReaderWriter.writer()
        let data = writer.writeBytes(bytes: [2,3,4]).done()
        XCTAssertEqual(data.count, 4 + 3)   // size with Uin32 4 bytes + data 3 bytes
        XCTAssertEqual(data[4], 2)
        XCTAssertEqual(data[5], 3)
        XCTAssertEqual(data[6], 4)
    }
    
    func testReadBytes() {
        let writer = ReaderWriter.writer()
        let reader = ReaderWriter.reader(with: Data(writer.writeBytes(bytes: [1,2,3]).done()))
        XCTAssertEqual(reader.readBytes(), [1,2,3])
        XCTAssert(!reader.hasMore())
    }
    
    func testWriteData() {
        let writer = ReaderWriter.writer()
        let testData = Data([3,4,5,6])
        let data = writer.writeData(data: testData).done()
        XCTAssertEqual(data.count, 4 + 4)   // size with Uin32 4 bytes + data 4 bytes
        XCTAssert(data[4..<8].elementsEqual(testData))
    }
    
    func testReadData() {
        let writer = ReaderWriter.writer()
        let reader = ReaderWriter.reader(with: Data(writer.writeData(data: Data([5,6,7,8])).done()))
        XCTAssertEqual([UInt8](reader.readData()), [5,6,7,8])
        XCTAssert(!reader.hasMore())
    }
    
    func testWriteUTF8() {
        let writer = ReaderWriter.writer()
        let testData = "តើមានអ្វីកើតឡើង? what happen ?"
        let data = writer.writeUTF8(text: testData).done()
        let total =  4 + testData.utf8.count
        XCTAssertEqual(data.count, total)   // size with Uin32 4 bytes + data utf size
        XCTAssert(data[4..<total].elementsEqual(testData.utf8))
        XCTAssertEqual(String(bytes: data[4..<total], encoding: .utf8), testData)
    }
    
    func testReadUTF8() {
        let writer = ReaderWriter.writer()
        let testData = "តើមានអ្វីកើតឡើង? what happen ?"
        let reader = ReaderWriter.reader(with: Data(writer.writeUTF8(text: testData).done()))
        XCTAssertEqual(reader.readUTF8(), testData)
        XCTAssert(!reader.hasMore())
    }
    
    func testWriteValue() {
        // test null
        var writer = ReaderWriter.writer()
        var data = writer.write(value: nil).done()
        XCTAssertEqual(data.count, 1)
        XCTAssertEqual(data[0], UInt8(DataType.null.rawValue))
        
        // test true bool
        writer = ReaderWriter.writer()
        data = writer.write(value: true).done()
        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data[0], UInt8(DataType.bool.rawValue))
        XCTAssertEqual(data[1], 1)
        
        // test false bool
        writer = ReaderWriter.writer()
        data = writer.write(value: false).done()
        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data[0], UInt8(DataType.bool.rawValue))
        XCTAssertEqual(data[1], 0)
        
        // test int32
        writer = ReaderWriter.writer()
        data = writer.write(value: 5).done()
        XCTAssertEqual(data.count, 5)   // 1 byte identified data type and 4 bytes for integer 32 bits.
        XCTAssertEqual(data[0], UInt8(DataType.int32.rawValue))
        XCTAssertEqual(data[1..<5], [5,0,0,0])
        
        // test int64
        writer = ReaderWriter.writer()
        let testLongInt =  0x7fffffff + 1
        data = writer.write(value: testLongInt).done()
        XCTAssertEqual(data.count, 9)   // 1 byte identified data type and 8 bytes for integer 64 bits.
        XCTAssertEqual(data[0], UInt8(DataType.int64.rawValue))
        XCTAssertEqual(data[1..<9].withUnsafeBytes{ $0.baseAddress!.assumingMemoryBound(to: Int64.self).pointee }, Int64(testLongInt))
        
        // test float
        writer = ReaderWriter.writer()
        let testFloat = Float(1.2)
        data = writer.write(value: testFloat).done()
        XCTAssertEqual(data.count, 9)   // 1 byte identified data type and 8 bytes for double or float64 64 bits.
        XCTAssertEqual(data[0], UInt8(DataType.float64.rawValue))
        XCTAssertEqual(data[1..<9].withUnsafeBytes{ $0.baseAddress!.assumingMemoryBound(to: Float64.self).pointee }, Float64(testFloat))
        
        // test double
        writer = ReaderWriter.writer()
        let testDouble = Double(1.2)
        data = writer.write(value: testDouble).done()
        XCTAssertEqual(data.count, 9)   // 1 byte identified data type and 8 bytes for double or float64 64 bits.
        XCTAssertEqual(data[0], UInt8(DataType.float64.rawValue))
        XCTAssertEqual(data[1..<9].withUnsafeBytes{ $0.baseAddress!.assumingMemoryBound(to: Double.self).pointee }, testDouble)
        
        // test string
        writer = ReaderWriter.writer()
        let testString = "តើមានអ្វីកើតឡើង? what happen ?"
        data = writer.write(value: testString).done()
        XCTAssertEqual(data.count, 1 + 4 + testString.utf8.count)   // 1 byte identified data type + 4 bytes data size + utf8 bytes count
        XCTAssertEqual(data[0], UInt8(DataType.string.rawValue))
        XCTAssertEqual(data[1..<4].withUnsafeBytes{ $0.baseAddress!.assumingMemoryBound(to: Int32.self).pointee }, Int32(testString.utf8.count))
        XCTAssertEqual(String(bytes: data[5...], encoding: .utf8), testString)
        
        // test array uint8 or bytes
        writer = ReaderWriter.writer()
        let bytes:[UInt8] = [1,2,3,4]
        data = writer.write(value: bytes).done()
        XCTAssertEqual(data.count, 1 + 4 + 4)   // 1 byte identified data type + 4 bytes data size + actual bytes
        XCTAssertEqual(data[0], UInt8(DataType.uint8List.rawValue))
        XCTAssertEqual(data[1..<4].withUnsafeBytes{ $0.baseAddress!.assumingMemoryBound(to: Int32.self).pointee }, Int32(bytes.count))
        XCTAssertEqual(Array(data[5...]), bytes)
        
        // test array int32 or bytes
        writer = ReaderWriter.writer()
        let arrInt32:[Int32] = [10,11,12,13]
        var bytesCount = Int32(arrInt32.count * 4)
        data = writer.write(value: arrInt32).done()
        XCTAssertEqual(data.count, Int(1 + 4 + bytesCount))   // 1 byte identified data type + 4 bytes data size + actual bytes
        XCTAssertEqual(data[0], UInt8(DataType.int32List.rawValue))
        XCTAssertEqual(data[1..<4].withUnsafeBytes{ $0.baseAddress!.assumingMemoryBound(to: Int32.self).pointee }, bytesCount)
        XCTAssertEqual(Array(data[5...]), arrInt32.withUnsafeBytes{ [UInt8]($0) })
        
        // test array int64 or bytes
        writer = ReaderWriter.writer()
        let arrInt64:[Int64] = [64,65,66,67]
        bytesCount = Int32(arrInt64.count * 8)
        data = writer.write(value: arrInt64).done()
        XCTAssertEqual(data.count, Int(1 + 4 + bytesCount))   // 1 byte identified data type + 4 bytes data size + actual bytes
        XCTAssertEqual(data[0], UInt8(DataType.int64List.rawValue))
        XCTAssertEqual(data[1..<4].withUnsafeBytes{ $0.baseAddress!.assumingMemoryBound(to: Int32.self).pointee }, bytesCount)
        XCTAssertEqual(Array(data[5...]), arrInt64.withUnsafeBytes{ [UInt8]($0) })
        
        // test array float64 or bytes
        writer = ReaderWriter.writer()
        let arrFloat64:[Float64] = [70.1,60.1,50.1,40.1]
        bytesCount = Int32(arrFloat64.count * 8)
        data = writer.write(value: arrFloat64).done()
        XCTAssertEqual(data.count, Int(1 + 4 + bytesCount))   // 1 byte identified data type + 4 bytes data size + actual bytes
        XCTAssertEqual(data[0], UInt8(DataType.float64List.rawValue))
        XCTAssertEqual(data[1..<4].withUnsafeBytes{ $0.baseAddress!.assumingMemoryBound(to: Int32.self).pointee }, bytesCount)
        XCTAssertEqual(Array(data[5...]), arrFloat64.withUnsafeBytes{ [UInt8]($0) })
        
        // test list any
        writer = ReaderWriter.writer()
        let arrAny:[Any] = [Double(1.2), 1, "message"];
        bytesCount = 8 + 4 + 7 + 4 + 3  // 8 for double + 4 for int32 + 7 for string + 4 bytes for string length + 3 bytes message identifier
        data = writer.write(value: arrAny).done()
        XCTAssertEqual(data.count, Int(1 + 4 + bytesCount))   // 1 byte identified data type + 4 bytes data size + actual bytes
        XCTAssertEqual(data[0], UInt8(DataType.list.rawValue))
        XCTAssertEqual(data[1..<4].withUnsafeBytes{ $0.baseAddress!.assumingMemoryBound(to: Int32.self).pointee }, Int32(arrAny.count))
        // TODO: test binary data with readValue
        
        // test map any
        writer = ReaderWriter.writer()
        let mapAny:[AnyHashable: Any] = [1: Double(1.0), "key": 28];
        bytesCount = 4 + 8 + 3 + 4 + 4 + 4  // 4 bytes key int + 8 for double + 3 for string + 4 bytes for string length + 4 bytes for int value + 4 bytes message identifier
        data = writer.write(value: mapAny).done()
        XCTAssertEqual(data.count, Int(1 + 4 + bytesCount))   // 1 byte identified data type + 4 bytes data size + actual bytes
        XCTAssertEqual(data[0], UInt8(DataType.map.rawValue))
        XCTAssertEqual(data[1..<4].withUnsafeBytes{ $0.baseAddress!.assumingMemoryBound(to: Int32.self).pointee }, Int32(mapAny.count))
        // TODO: test binary data with readValue
        
        // test write protobuf message
        writer = ReaderWriter.writer()
        var message = Photo()
        message.name = "DCAOM-3029.JPG"
        message.width = 300
        message.height = 100
        message.localIdentifier = "9a7261f7-bcb1-4bd5-9c02-330ef0b86e2e"
        message.fileSize = 1000000
        let binData = try! message.serializedData()
        data = writer.write(value: message).done()
        XCTAssertEqual(data.count, Int(1 + 4 + binData.count))
        XCTAssertEqual(data[0], UInt8(DataType.message.rawValue))
        XCTAssertEqual(data[1..<4].withUnsafeBytes{ $0.baseAddress!.assumingMemoryBound(to: Int32.self).pointee }, Int32(binData.count))
        XCTAssertEqual(Array(data[5...]), [UInt8](binData))
    }
    
    func testReadValue() {
        // test null
        var writer = ReaderWriter.writer()
        var reader = ReaderWriter.reader(with: Data(writer.write(value: nil).done()))
        XCTAssert(reader.readValue() == nil)
        XCTAssert(!reader.hasMore())

        writer = ReaderWriter.writer()
        reader = ReaderWriter.reader(with: Data(writer.write(value: true).done()))
        XCTAssert(reader.readValue() == true)
        XCTAssert(!reader.hasMore())

        writer = ReaderWriter.writer()
        reader = ReaderWriter.reader(with: Data(writer.write(value: false).done()))
        XCTAssert(reader.readValue() == false)
        XCTAssert(!reader.hasMore())

        writer = ReaderWriter.writer()
        reader = ReaderWriter.reader(with: Data(writer.write(value: 1).done()))
        XCTAssert(reader.readValue() == 1)
        XCTAssert(!reader.hasMore())

        writer = ReaderWriter.writer()
        let testLongInt =  0x7fffffff + 1
        reader = ReaderWriter.reader(with: Data(writer.write(value: testLongInt).done()))
        XCTAssert(reader.readValue() == testLongInt)
        XCTAssert(!reader.hasMore())

        writer = ReaderWriter.writer()
        reader = ReaderWriter.reader(with: Data(writer.write(value: 21.0).done()))
        XCTAssert(reader.readValue() == 21.0)
        XCTAssert(!reader.hasMore())

        writer = ReaderWriter.writer()
        let testData = "តើមានអ្វីកើតឡើង? what happen ?"
        reader = ReaderWriter.reader(with: Data(writer.write(value: testData).done()))
        XCTAssert(reader.readValue() == testData)
        XCTAssert(!reader.hasMore())
        
        writer = ReaderWriter.writer()
        let arrUint8: [UInt8] = [4,5,6,7]
        reader = ReaderWriter.reader(with: Data(writer.write(value: arrUint8).done()))
        XCTAssert(reader.readValue() == arrUint8)
        XCTAssert(!reader.hasMore())
        
        writer = ReaderWriter.writer()
        let arrInt32: [Int32] = [10,11,12,13]
        reader = ReaderWriter.reader(with: Data(writer.write(value: arrInt32).done()))
        XCTAssert(reader.readValue() == arrInt32)
        XCTAssert(!reader.hasMore())
        
        writer = ReaderWriter.writer()
        let arrInt64: [Int64] = [100,110,120,130]
        reader = ReaderWriter.reader(with: Data(writer.write(value: arrInt64).done()))
        XCTAssert(reader.readValue() == arrInt64)
        XCTAssert(!reader.hasMore())
        
        writer = ReaderWriter.writer()
        let arrDouble: [Double] = [10.11,11.34,12.76,13.304]
        reader = ReaderWriter.reader(with: Data(writer.write(value: arrDouble).done()))
        XCTAssert(reader.readValue() == arrDouble)
        XCTAssert(!reader.hasMore())
        
        writer = ReaderWriter.writer()
        let arrAny: [Any?] = [100, "test", 10.11]
        reader = ReaderWriter.reader(with: Data(writer.write(value: arrAny).done()))
        let valArrAny: [Any?]? = reader.readValue()
        XCTAssert(valArrAny != nil)
        XCTAssert(valArrAny!.count == arrAny.count)
        XCTAssert(valArrAny![0] is Int)
        XCTAssert(valArrAny![1] is String)
        XCTAssert(valArrAny![2] is Double)
        XCTAssert(valArrAny![0] as! Int == arrAny[0] as! Int)
        XCTAssert(valArrAny![1] as! String == arrAny[1] as! String)
        XCTAssert(valArrAny![2] as! Double == arrAny[2] as! Double)
        XCTAssert(!reader.hasMore())
        
        writer = ReaderWriter.writer()
        let mapAny: [AnyHashable: Any?] = [1: 1.0, "test": 20]
        reader = ReaderWriter.reader(with: Data(writer.write(value: mapAny).done()))
        let valMapAny: [AnyHashable: Any?]? = reader.readValue()
        XCTAssert(valMapAny != nil)
        XCTAssert(valMapAny!.count == mapAny.count)
        XCTAssertEqual(valMapAny!.keys, mapAny.keys)
        for (key, val) in valMapAny! {
            XCTAssert(type(of: val!) == type(of: mapAny[key]!!), "\(type(of: val!)) is not equal to \(type(of: mapAny[key]!!))")
        }
        XCTAssertEqual(valMapAny![1] as! Double, mapAny[1] as! Double)
        XCTAssertEqual(valMapAny!["test"] as! Int, mapAny["test"] as! Int)
        XCTAssert(!reader.hasMore())
        
        writer = ReaderWriter.writer()
        var message = Photo()
        message.name = "DCAOM-3029.JPG"
        message.width = 300
        message.height = 100
        message.localIdentifier = "9a7261f7-bcb1-4bd5-9c02-330ef0b86e2e"
        message.fileSize = 1000000
        reader = ReaderWriter.reader(with: Data(writer.write(value: message).done()))
        let resultMessage: Photo? = reader.readValue()
        XCTAssert(resultMessage != nil)
        XCTAssertEqual(resultMessage, message)
        XCTAssert(!reader.hasMore())
    }

}
