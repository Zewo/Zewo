//===----------------------------------------------------------------------===//
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0
//
//===----------------------------------------------------------------------===//

import Core
import Venice
import Foundation

extension JSON {
    /// The formatting of the output JSON data.
    public enum OutputFormatting {
        /// Produce JSON compacted by removing whitespace. This is the default formatting.
        case compact
        
        /// Produce human-readable JSON with indented output.
        case prettyPrinted
    }
    
    /// The strategy to use for encoding `Date` values.
    public enum DateEncodingStrategy {
        /// Defer to `Date` for choosing an encoding. This is the default strategy.
        case deferredToDate
        
        /// Encode the `Date` as a UNIX timestamp (as a JSON number).
        case secondsSince1970
        
        /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
        case millisecondsSince1970
        
        /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601
        
        /// Encode the `Date` as a string formatted by the given formatter.
        case formatted(DateFormatter)
        
        /// Encode the `Date` as a custom value encoded by the given closure.
        ///
        /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
        case custom((Date, Encoder) throws -> Void)
    }
    
    /// The strategy to use for encoding `Data` values.
    public enum DataEncodingStrategy {
        /// Encoded the `Data` as a Base64-encoded string. This is the default strategy.
        case base64Encode
        
        /// Encode the `Data` as a custom value encoded by the given closure.
        ///
        /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
        case custom((Data, Encoder) throws -> Void)
    }
    
    /// The strategy to use for non-JSON-conforming floating-point values (IEEE 754 infinity and NaN).
    public enum NonConformingFloatEncodingStrategy {
        /// Throw upon encountering non-conforming values. This is the default strategy.
        case `throw`
        
        /// Encode the values using the given representation strings.
        case convertToString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }
    
    /// Options set on the top-level encoder to pass down the encoding hierarchy.
    public struct EncodingOptions {
        var dateEncodingStrategy: DateEncodingStrategy = .deferredToDate
        var dataEncodingStrategy: DataEncodingStrategy = .base64Encode
        var nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy = .throw
        var userInfo: [CodingUserInfoKey: Any] = [:]
    }
    
    /// Encodes the given top-level value and returns its JSON representation.
    ///
    /// - parameter value: The value to encode.
    /// - returns: A new `JSON` value containing the encoded JSON data.
    /// - throws: `EncodingError.invalidValue` if a non-comforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - throws: An error if any value throws an error during encoding.
    public static func encode<T : Encodable>(
        _ value: T,
        options: EncodingOptions = EncodingOptions()
    ) throws -> JSON {
        let encoder = _JSONEncoder(options: options)
        try value.encode(to: encoder)
        
        guard encoder.storage.count > 0 else {
            let context = EncodingError.Context(
                codingPath: [],
                debugDescription: "Top-level \(T.self) did not encode any values."
            )
            
            throw EncodingError.invalidValue(value, context)
        }
        
        let topLevel = encoder.storage.popContainer()
        
        if topLevel.isNull {
            let context = EncodingError.Context(
                codingPath: [],
                debugDescription: "Top-level \(T.self) encoded as null JSON fragment."
            )
            
            throw EncodingError.invalidValue(value, context)
        } else if topLevel.isNumber {
            let context = EncodingError.Context(
                codingPath: [],
                debugDescription: "Top-level \(T.self) encoded as number JSON fragment."
            )
            
            throw EncodingError.invalidValue(value, context)
        } else if topLevel.isString {
            let context = EncodingError.Context(
                codingPath: [],
                debugDescription: "Top-level \(T.self) encoded as string JSON fragment."
            )
            
            throw EncodingError.invalidValue(value, context)
        } else if topLevel.isBool {
            let context = EncodingError.Context(
                codingPath: [],
                debugDescription: "Top-level \(T.self) encoded as boolean JSON fragment."
            )
            
            throw EncodingError.invalidValue(value, context)
        }
        
        return topLevel
    }
    
    public static func encode<T : Encodable>(
        _ value: T,
        to writable: Writable,
        deadline: Deadline,
        options: EncodingOptions
    ) throws {
        let json = try encode(value, options: options)
        try json.serialize(to: writable, deadline: deadline)
    }
    
    public static func encode<T>(
        _ value: T,
        to writable: Writable,
        deadline: Deadline
    ) throws where T : Encodable {
        try self.encode(
            value,
            to: writable,
            deadline: deadline,
            options: EncodingOptions()
        )
    }
}

fileprivate class _JSONEncoder : Encoder {
    /// The encoder's storage.
    var storage: _JSONEncodingStorage
    
    /// Options set on the top-level encoder.
    let options: JSON.EncodingOptions
    
    /// The path to the current point in encoding.
    var codingPath: [CodingKey?]
    
    /// Contextual user-provided information for use during encoding.
    var userInfo: [CodingUserInfoKey : Any] {
        return self.options.userInfo
    }
    
    /// Initializes `self` with the given top-level encoder options.
    init(options: JSON.EncodingOptions, codingPath: [CodingKey?] = []) {
        self.options = options
        self.storage = _JSONEncodingStorage()
        self.codingPath = codingPath
    }
    
    /// Performs the given closure with the given key pushed onto the end of the current coding path.
    ///
    /// - parameter key: The key to push. May be nil for unkeyed containers.
    /// - parameter work: The work to perform with the key in the path.
    func with<T>(pushedKey key: CodingKey?, _ work: () throws -> T) rethrows -> T {
        self.codingPath.append(key)
        let ret: T = try work()
        self.codingPath.removeLast()
        return ret
    }
    
    /// Returns whether a new element can be encoded at this coding path.
    ///
    /// `true` if an element has not yet been encoded at this coding path; `false` otherwise.
    var canEncodeNewElement: Bool {
        // Every time a new value gets encoded, the key it's encoded for is pushed onto the coding path (even if it's a nil key from an unkeyed container).
        // At the same time, every time a container is requested, a new value gets pushed onto the storage stack.
        // If there are more values on the storage stack than on the coding path, it means the value is requesting more than one container, which violates the precondition.
        //
        // This means that anytime something that can request a new container goes onto the stack, we MUST push a key onto the coding path.
        // Things which will not request containers do not need to have the coding path extended for them (but it doesn't matter if it is, because they will not reach here).
        return self.storage.count == self.codingPath.count
    }
    
    /// Asserts that a new container can be requested at this coding path.
    /// `preconditionFailure()`s if one cannot be requested.
    func assertCanRequestNewContainer() {
        guard self.canEncodeNewElement else {
            let previousContainerType: String
            
            if self.storage.containers.last?.isObject == true {
                previousContainerType = "keyed"
            } else if self.storage.containers.last?.isArray == true {
                previousContainerType = "unkeyed"
            } else {
                previousContainerType = "single value"
            }
            
            preconditionFailure("Attempt to encode with new container when already encoded with \(previousContainerType) container.")
        }
    }
    
    func container<Key>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
        assertCanRequestNewContainer()
        self.storage.pushKeyedContainer()
        
        let container = _JSONKeyedEncodingContainer<Key>(
            referencing: self,
            codingPath: self.codingPath
        )
        
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        assertCanRequestNewContainer()
        self.storage.pushUnkeyedContainer()
        
        return _JSONUnkeyedEncodingContainer(
            referencing: self,
            codingPath: self.codingPath
        )
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        assertCanRequestNewContainer()
        return self
    }
}

fileprivate struct _JSONEncodingStorage {
    /// The container stack.
    /// Elements may be any one of the JSON types (NSNull, NSNumber, NSString, NSArray, NSDictionary).
    private(set) var containers: [JSON] = []
    
    /// Initializes `self` with no containers.
    init() {}
    
    var count: Int {
        return self.containers.count
    }
    
    mutating func pushKeyedContainer() {
        self.containers.append([:])
    }
    
    mutating func set(_ value: JSON, forKey key: String) {
        guard let top = self.containers.popLast() else {
            return
        }
        
        guard case var .object(object) = top else {
            return
        }
        
        object[key] = value
        
        self.containers.append(.object(object))
    }
    
    mutating func append(_ value: JSON) {
        guard let top = self.containers.popLast() else {
            return
        }
        
        guard case var .array(array) = top else {
            return
        }
        
        array.append(value)
        
        self.containers.append(.array(array))
    }
    
    mutating func pushUnkeyedContainer() {
        self.containers.append([])
    }
    
    mutating func push(container: JSON) {
        self.containers.append(container)
    }
    
    mutating func popContainer() -> JSON {
        precondition(self.containers.count > 0, "Empty container stack.")
        return self.containers.popLast()!
    }
}

fileprivate final class _JSONKeyedEncodingContainer<K : CodingKey> : KeyedEncodingContainerProtocol {
    typealias Key = K
    
    /// A reference to the encoder we're writing to.
    let encoder: _JSONEncoder
    
    /// The path of coding keys taken to get to this point in encoding.
    var codingPath: [CodingKey?]
    
    /// Initializes `self` with the given references.
    init(
        referencing encoder: _JSONEncoder,
        codingPath: [CodingKey?]
    ) {
        self.encoder = encoder
        self.codingPath = codingPath
    }
    
    /// Performs the given closure with the given key pushed onto the end of the current coding path.
    ///
    /// - parameter key: The key to push. May be nil for unkeyed containers.
    /// - parameter work: The work to perform with the key in the path.
    func with<T>(pushedKey key: CodingKey?, _ work: () throws -> T) rethrows -> T {
        self.codingPath.append(key)
        let ret: T = try work()
        self.codingPath.removeLast()
        return ret
    }
    
    func encode(_ value: Bool, forKey key: Key) throws {
        self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
    }
    
    func encode(_ value: Int, forKey key: Key) throws {
        self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
    }
    
    func encode(_ value: Int8, forKey key: Key) throws {
        self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
    }
    
    func encode(_ value: Int16, forKey key: Key) throws {
        self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
    }
    
    func encode(_ value: Int32, forKey key: Key) throws {
        self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
    }
    
    func encode(_ value: Int64, forKey key: Key) throws {
        self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
    }
    
    func encode(_ value: UInt, forKey key: Key) throws {
        self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
    }
    
    func encode(_ value: UInt8, forKey key: Key) throws {
        self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
    }
    
    func encode(_ value: UInt16, forKey key: Key) throws {
        self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
    }
    
    func encode(_ value: UInt32, forKey key: Key) throws {
        self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
    }
    
    func encode(_ value: UInt64, forKey key: Key) throws {
        self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
    }
    
    func encode(_ value: String, forKey key: Key) throws {
        self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
    }
    
    func encode(_ value: Float, forKey key: Key)  throws {
        // Since the float may be invalid and throw, the coding path needs to contain this key.
        try self.encoder.with(pushedKey: key) {
            try self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
        }
    }
    
    func encode(_ value: Double, forKey key: Key) throws {
        // Since the double may be invalid and throw, the coding path needs to contain this key.
        try self.encoder.with(pushedKey: key) {
            try self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
        }
    }
    
    func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
        try self.encoder.with(pushedKey: key) {
            try self.encoder.storage.set(self.encoder.box(value), forKey: key.stringValue)
        }
    }
    
    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> {
        self.encoder.storage.set([:], forKey: key.stringValue)
        
        return self.with(pushedKey: key) {
            let container = _JSONKeyedEncodingContainer<NestedKey>(
                referencing: self.encoder,
                codingPath: self.codingPath
            )
            
            return KeyedEncodingContainer(container)
        }
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        self.encoder.storage.set([], forKey: key.stringValue)
        
        return self.with(pushedKey: key) {
            return _JSONUnkeyedEncodingContainer(
                referencing: self.encoder,
                codingPath: self.codingPath
            )
        }
    }
    
    func superEncoder() -> Encoder {
        return _JSONReferencingEncoder(referencing: self.encoder, at: _JSONSuperKey.super) { value in
            self.encoder.storage.set(value, forKey: _JSONSuperKey.super.stringValue)
        }
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        return _JSONReferencingEncoder(referencing: self.encoder, at: key) { value in
            self.encoder.storage.set(value, forKey: key.stringValue)
        }
    }
}

fileprivate final class _JSONUnkeyedEncodingContainer : UnkeyedEncodingContainer {
    /// A reference to the encoder we're writing to.
    let encoder: _JSONEncoder
    
    /// The path of coding keys taken to get to this point in encoding.
    var codingPath: [CodingKey?]
    
    /// Initializes `self` with the given references.
    init(
        referencing encoder: _JSONEncoder,
        codingPath: [CodingKey?]
    ) {
        self.encoder = encoder
        self.codingPath = codingPath
    }
    
    /// Performs the given closure with the given key pushed onto the end of the current coding path.
    ///
    /// - parameter key: The key to push. May be nil for unkeyed containers.
    /// - parameter work: The work to perform with the key in the path.
    func with<T>(pushedKey key: CodingKey?, _ work: () throws -> T) rethrows -> T {
        self.codingPath.append(key)
        let ret: T = try work()
        self.codingPath.removeLast()
        return ret
    }
    
    func encode(_ value: Bool) throws {
        self.encoder.storage.append(self.encoder.box(value))
    }
    
    func encode(_ value: Int) throws {
        self.encoder.storage.append(self.encoder.box(value))
    }
    
    func encode(_ value: Int8) throws {
        self.encoder.storage.append(self.encoder.box(value))
    }
    
    func encode(_ value: Int16) throws {
        self.encoder.storage.append(self.encoder.box(value))
    }
    
    func encode(_ value: Int32) throws {
        self.encoder.storage.append(self.encoder.box(value))
    }
    
    func encode(_ value: Int64) throws {
        self.encoder.storage.append(self.encoder.box(value))
    }
    
    func encode(_ value: UInt) throws {
        self.encoder.storage.append(self.encoder.box(value))
    }
    
    func encode(_ value: UInt8) throws {
        self.encoder.storage.append(self.encoder.box(value))
    }
    
    func encode(_ value: UInt16) throws {
        self.encoder.storage.append(self.encoder.box(value))
    }
    
    func encode(_ value: UInt32) throws {
        self.encoder.storage.append(self.encoder.box(value))
    }
    
    func encode(_ value: UInt64) throws {
        self.encoder.storage.append(self.encoder.box(value))
    }
    
    func encode(_ value: String) throws {
        self.encoder.storage.append(self.encoder.box(value))
    }
    
    func encode(_ value: Float)  throws {
        // Since the float may be invalid and throw, the coding path needs to contain this key.
        try self.encoder.with(pushedKey: nil) {
            try self.encoder.storage.append(self.encoder.box(value))
        }
    }
    
    func encode(_ value: Double) throws {
        // Since the double may be invalid and throw, the coding path needs to contain this key.
        try self.encoder.with(pushedKey: nil) {
            try self.encoder.storage.append(self.encoder.box(value))
        }
    }
    
    func encode<T : Encodable>(_ value: T) throws {
        try self.encoder.with(pushedKey: nil) {
            try self.encoder.storage.append(self.encoder.box(value))
        }
    }
    
    func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> {
        self.encoder.storage.append([:])
        
        return self.with(pushedKey: nil) {
            let container = _JSONKeyedEncodingContainer<NestedKey>(
                referencing: self.encoder,
                codingPath: self.codingPath
            )
            
            return KeyedEncodingContainer(container)
        }
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.encoder.storage.append([])
        
        return self.with(pushedKey: nil) {
            return _JSONUnkeyedEncodingContainer(
                referencing: self.encoder,
                codingPath: self.codingPath
            )
        }
    }
    
    func superEncoder() -> Encoder {
        return _JSONReferencingEncoder(referencing: self.encoder, at: nil) { value in
            self.encoder.storage.append(value)
        }
    }
}

extension _JSONEncoder : SingleValueEncodingContainer {
    // MARK: - Utility Methods
    /// Asserts that a single value can be encoded at the current coding path (i.e. that one has not already been encoded through this container).
    /// `preconditionFailure()`s if one cannot be encoded.
    ///
    /// This is similar to assertCanRequestNewContainer above.
    func assertCanEncodeSingleValue() {
        guard self.canEncodeNewElement else {
            let previousContainerType: String
            if self.storage.containers.last?.isObject == true {
                previousContainerType = "keyed"
            } else if self.storage.containers.last?.isArray == true {
                previousContainerType = "unkeyed"
            } else {
                preconditionFailure("Attempt to encode multiple values in a single value container.")
            }
            
            preconditionFailure("Attempt to encode with new container when already encoded with \(previousContainerType) container.")
        }
    }
    
    // MARK: - SingleValueEncodingContainer Methods
    func encodeNil() throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: .null)
    }
    
    func encode(_ value: Bool) throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: box(value))
    }
    
    func encode(_ value: Int) throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: box(value))
    }
    
    func encode(_ value: Int8) throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: box(value))
    }
    
    func encode(_ value: Int16) throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: box(value))
    }
    
    func encode(_ value: Int32) throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: box(value))
    }
    
    func encode(_ value: Int64) throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: box(value))
    }
    
    func encode(_ value: UInt) throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: box(value))
    }
    
    func encode(_ value: UInt8) throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: box(value))
    }
    
    func encode(_ value: UInt16) throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: box(value))
    }
    
    func encode(_ value: UInt32) throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: box(value))
    }
    
    func encode(_ value: UInt64) throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: box(value))
    }
    
    func encode(_ value: String) throws {
        assertCanEncodeSingleValue()
        self.storage.push(container: box(value))
    }
    
    func encode(_ value: Float) throws {
        assertCanEncodeSingleValue()
        try self.storage.push(container: box(value))
    }
    
    func encode(_ value: Double) throws {
        assertCanEncodeSingleValue()
        try self.storage.push(container: box(value))
    }
    
    func encode<T : Encodable>(_ value: T) throws {
        assertCanEncodeSingleValue()
        try self.storage.push(container: box(value))
    }
}

// MARK: - Concrete Value Representations
extension _JSONEncoder {
    /// Returns the given value boxed in a container appropriate for pushing onto the container stack.
    fileprivate func box(_ value: Bool)   -> JSON { return .bool(value) }
    fileprivate func box(_ value: Int)    -> JSON { return .int(value) }
    fileprivate func box(_ value: Int8)   -> JSON { return .int(Int(value)) }
    fileprivate func box(_ value: Int16)  -> JSON { return .int(Int(value)) }
    fileprivate func box(_ value: Int32)  -> JSON { return .int(Int(value)) }
    fileprivate func box(_ value: Int64)  -> JSON { return .int(Int(value)) }
    fileprivate func box(_ value: UInt)   -> JSON { return .int(Int(value)) }
    fileprivate func box(_ value: UInt8)  -> JSON { return .int(Int(value)) }
    fileprivate func box(_ value: UInt16) -> JSON { return .int(Int(value)) }
    fileprivate func box(_ value: UInt32) -> JSON { return .int(Int(value)) }
    fileprivate func box(_ value: UInt64) -> JSON { return .int(Int(value)) }
    fileprivate func box(_ value: String) -> JSON { return .string(value) }
    
    fileprivate func box(_ float: Float) throws -> JSON {
        guard !float.isInfinite && !float.isNaN else {
            guard case let .convertToString(
                positiveInfinity: posInfString,
                negativeInfinity: negInfString,
                nan: nanString
            ) = self.options.nonConformingFloatEncodingStrategy else {
                throw EncodingError._invalidFloatingPointValue(float, at: codingPath)
            }
            
            if float == Float.infinity {
                return .string(posInfString)
            } else if float == -Float.infinity {
                return .string(negInfString)
            } else {
                return .string(nanString)
            }
        }
        
        return .double(Double(float))
    }
    
    fileprivate func box(_ double: Double) throws -> JSON {
        guard !double.isInfinite && !double.isNaN else {
            guard case let .convertToString(
                positiveInfinity: posInfString,
                negativeInfinity: negInfString,
                nan: nanString
            ) = self.options.nonConformingFloatEncodingStrategy else {
                throw EncodingError._invalidFloatingPointValue(double, at: codingPath)
            }
            
            if double == Double.infinity {
                return .string(posInfString)
            } else if double == -Double.infinity {
                return .string(negInfString)
            } else {
                return .string(nanString)
            }
        }
        
        return .double(double)
    }
    
    fileprivate func box(_ date: Date) throws -> JSON {
        switch self.options.dateEncodingStrategy {
        case .deferredToDate:
            // Must be called with a surrounding with(pushedKey:) call.
            try date.encode(to: self)
            return self.storage.popContainer()
            
        case .secondsSince1970:
            return .double(date.timeIntervalSince1970)
            
        case .millisecondsSince1970:
            return .double(1000.0 * date.timeIntervalSince1970)
            
        case .iso8601:
            if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                return .string(_iso8601Formatter.string(from: date))
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
            
        case .formatted(let formatter):
            return .string(formatter.string(from: date))
            
        case .custom(let closure):
            let depth = self.storage.count
            try closure(date, self)
            
            guard self.storage.count > depth else {
                // The closure didn't encode anything. Return the default keyed container.
                return [:]
            }
            
            // We can pop because the closure encoded something.
            return self.storage.popContainer()
        }
    }
    
    fileprivate func box(_ data: Data) throws -> JSON {
        switch self.options.dataEncodingStrategy {
        case .base64Encode:
            return .string(data.base64EncodedString())
            
        case .custom(let closure):
            let depth = self.storage.count
            try closure(data, self)
            
            guard self.storage.count > depth else {
                // The closure didn't encode anything. Return the default keyed container.
                return [:]
            }
            
            // We can pop because the closure encoded something.
            return self.storage.popContainer()
        }
    }
    
    fileprivate func box<T : Encodable>(_ value: T) throws -> JSON {
        if T.self == Date.self {
            // Respect Date encoding strategy
            return try self.box((value as! Date))
        } else if T.self == Data.self {
            // Respect Data encoding strategy
            return try self.box((value as! Data))
        } else if T.self == URL.self {
            // Encode URLs as single strings.
            return self.box((value as! URL).absoluteString)
        }
        
        // The value should request a container from the _JSONEncoder.
        let topContainer = self.storage.containers.last
        try value.encode(to: self)
        
        
        // TODO: Figure this out!
//        
//        // The top container should be a new container.
//        guard self.storage.containers.last! !== topContainer else {
//            // If the value didn't request a container at all, encode the default container instead.
//            return [:]
//        }
        
        return self.storage.popContainer()
    }
}

/// _JSONReferencingEncoder is a special subclass of _JSONEncoder which has its own storage, but references the contents of a different encoder.
/// It's used in superEncoder(), which returns a new encoder for encoding a superclass -- the lifetime of the encoder should not escape the scope it's created in, but it doesn't necessarily know when it's done being used (to write to the original container).
fileprivate class _JSONReferencingEncoder : _JSONEncoder {
    /// The encoder we're referencing.
    let encoder: _JSONEncoder
    
    /// Function that writes the contents of our storage to the referenced encoder's storage.
    let write: (JSON) -> Void
    
    /// Initializes `self` by referencing the given array container in the given encoder.
    init(referencing encoder: _JSONEncoder, at key: CodingKey?, write: @escaping (JSON) -> Void) {
        self.encoder = encoder
        self.write = write
        super.init(options: encoder.options, codingPath: encoder.codingPath)
        self.codingPath.append(key)
    }
    
    override var canEncodeNewElement: Bool {
        // With a regular encoder, the storage and coding path grow together.
        // A referencing encoder, however, inherits its parents coding path, as well as the key it was created for.
        // We have to take this into account.
        return self.storage.count == self.codingPath.count - self.encoder.codingPath.count - 1
    }
    
    // Finalizes `self` by writing the contents of our storage to the referenced encoder's storage.
    deinit {
        let value: JSON
        
        switch self.storage.count {
        case 0: value = [:]
        case 1: value = self.storage.popContainer()
        default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }
        
        self.write(value)
    }
}
