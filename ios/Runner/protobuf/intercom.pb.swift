// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: protobuf/intercom.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

enum ValidMethod: SwiftProtobuf.Enum {
  typealias RawValue = Int
  case unknown // = 0
  case getPhoto // = 1
  case listPhotos // = 2
  case getPhotoMetadata // = 3
  case removePhotoMetadata // = 4
  case UNRECOGNIZED(Int)

  init() {
    self = .unknown
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .unknown
    case 1: self = .getPhoto
    case 2: self = .listPhotos
    case 3: self = .getPhotoMetadata
    case 4: self = .removePhotoMetadata
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .unknown: return 0
    case .getPhoto: return 1
    case .listPhotos: return 2
    case .getPhotoMetadata: return 3
    case .removePhotoMetadata: return 4
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ValidMethod: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [ValidMethod] = [
    .unknown,
    .getPhoto,
    .listPhotos,
    .getPhotoMetadata,
    .removePhotoMetadata,
  ]
}

#endif  // swift(>=4.2)

struct CallingMethod {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var name: String {
    get {return _storage._name}
    set {_uniqueStorage()._name = newValue}
  }

  var package: String {
    get {return _storage._package}
    set {_uniqueStorage()._package = newValue}
  }

  var arguments: SwiftProtobuf.Google_Protobuf_Any {
    get {return _storage._arguments ?? SwiftProtobuf.Google_Protobuf_Any()}
    set {_uniqueStorage()._arguments = newValue}
  }
  /// Returns true if `arguments` has been explicitly set.
  var hasArguments: Bool {return _storage._arguments != nil}
  /// Clears the value of `arguments`. Subsequent reads from it will return its default value.
  mutating func clearArguments() {_uniqueStorage()._arguments = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension ValidMethod: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "UNKNOWN"),
    1: .same(proto: "GET_PHOTO"),
    2: .same(proto: "LIST_PHOTOS"),
    3: .same(proto: "GET_PHOTO_METADATA"),
    4: .same(proto: "REMOVE_PHOTO_METADATA"),
  ]
}

extension CallingMethod: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "CallingMethod"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .same(proto: "package"),
    3: .same(proto: "arguments"),
  ]

  fileprivate class _StorageClass {
    var _name: String = String()
    var _package: String = String()
    var _arguments: SwiftProtobuf.Google_Protobuf_Any? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _name = source._name
      _package = source._package
      _arguments = source._arguments
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1: try decoder.decodeSingularStringField(value: &_storage._name)
        case 2: try decoder.decodeSingularStringField(value: &_storage._package)
        case 3: try decoder.decodeSingularMessageField(value: &_storage._arguments)
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._name.isEmpty {
        try visitor.visitSingularStringField(value: _storage._name, fieldNumber: 1)
      }
      if !_storage._package.isEmpty {
        try visitor.visitSingularStringField(value: _storage._package, fieldNumber: 2)
      }
      if let v = _storage._arguments {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: CallingMethod, rhs: CallingMethod) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._name != rhs_storage._name {return false}
        if _storage._package != rhs_storage._package {return false}
        if _storage._arguments != rhs_storage._arguments {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
