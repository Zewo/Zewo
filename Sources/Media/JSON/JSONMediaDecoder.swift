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
    /// The strategy to use for decoding `Date` values.
    public enum DateDecodingStrategy {
        /// Defer to `Date` for decoding. This is the default strategy.
        case deferredToDate
        
        /// Decode the `Date` as a UNIX timestamp from a JSON number.
        case secondsSince1970
        
        /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
        case millisecondsSince1970
        
        /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601
        
        /// Decode the `Date` as a string parsed by the given formatter.
        case formatted(DateFormatter)
        
        /// Decode the `Date` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Date)
    }
    
    /// The strategy to use for decoding `Data` values.
    public enum DataDecodingStrategy {
        /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
        case base64Decode
        
        /// Decode the `Data` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Data)
    }
    
    /// The strategy to use for non-JSON-conforming floating-point values (IEEE 754 infinity and NaN).
    public enum NonConformingFloatDecodingStrategy {
        /// Throw upon encountering non-conforming values. This is the default strategy.
        case `throw`
        
        /// Decode the values from the given representation strings.
        case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }
    
    /// Options set on the top-level encoder to pass down the decoding hierarchy.
    public struct DecodingOptions {
        var dateDecodingStrategy: DateDecodingStrategy = .deferredToDate
        var dataDecodingStrategy: DataDecodingStrategy = .base64Decode
        let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw
        var userInfo: [CodingUserInfoKey: Any] = [:]
    }
    
    /// Decodes a top-level value of the given type from the given JSON representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter json: The JSON data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
    /// - throws: An error if any value throws an error during decoding.
    public static func decode<T : Decodable>(
        _ json: JSON,
        options: DecodingOptions = DecodingOptions()
    ) throws -> T {
        let decoder = _JSONDecoder(referencing: json, options: options)
        return try T(from: decoder)
    }
    
    public static func decode<T : Decodable>(
        from readable: Readable,
        deadline: Deadline,
        options: DecodingOptions
    ) throws -> T {
        let json = try parse(from: readable, deadline: deadline)
        return try decode(json, options: options)
    }
    
    public static func decode<T : Decodable>(
        from readable: Readable,
        deadline: Deadline
    ) throws -> T {
        return try decode(
            from: readable,
            deadline: deadline,
            options: DecodingOptions()
        )
    }
}

fileprivate class _JSONDecoder : Decoder {
    /// The decoder's storage.
    var storage: _JSONDecodingStorage
    
    /// Options set on the top-level decoder.
    let options: JSON.DecodingOptions
    
    /// The path to the current point in encoding.
    var codingPath: [CodingKey?]
    
    /// Contextual user-provided information for use during encoding.
    var userInfo: [CodingUserInfoKey : Any] {
        return self.options.userInfo
    }
    
    /// Initializes `self` with the given top-level container and options.
    init(
        referencing container: JSON,
        at codingPath: [CodingKey?] = [],
        options: JSON.DecodingOptions
    ) {
        self.storage = _JSONDecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
        self.options = options
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
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard !self.storage.topContainer.isNull else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Cannot get keyed decoding container -- found null value instead."
            )
            
            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self, context)
        }
        
        guard case let .object(object) = self.storage.topContainer else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: [String: Any].self,
                reality: self.storage.topContainer
            )
        }
        
        let container = _JSONKeyedDecodingContainer<Key>(
            referencing: self,
            wrapping: object
        )
        
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !self.storage.topContainer.isNull else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Cannot get unkeyed decoding container -- found null value instead."
            )
            
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
        }
        
        guard case let .array(array) = self.storage.topContainer else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: [Any].self,
                reality: self.storage.topContainer
            )
        }
        
        return _JSONUnkeyedDecodingContainer(
            referencing: self,
            wrapping: array
        )
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        guard !self.storage.topContainer.isObject else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Cannot get single value decoding container -- found keyed container instead."
            )
            
            throw DecodingError.typeMismatch(SingleValueDecodingContainer.self, context)
        }
        
        guard !self.storage.topContainer.isArray else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Cannot get single value decoding container -- found unkeyed container instead."
            )
            
            throw DecodingError.typeMismatch(SingleValueDecodingContainer.self, context)
        }
        
        return self
    }
}

fileprivate struct _JSONDecodingStorage {
    /// The container stack.
    /// Elements may be any one of the JSON types (NSNull, NSNumber, String, Array, [String : Any]).
    private(set) var containers: [JSON] = []
    
    /// Initializes `self` with no containers.
    init() {}
    
    var count: Int {
        return self.containers.count
    }
    
    var topContainer: JSON {
        precondition(self.containers.count > 0, "Empty container stack.")
        return self.containers.last!
    }
    
    mutating func push(container: JSON) {
        self.containers.append(container)
    }
    
    mutating func popContainer() {
        precondition(self.containers.count > 0, "Empty container stack.")
        self.containers.removeLast()
    }
}

fileprivate struct _JSONKeyedDecodingContainer<K : CodingKey> : KeyedDecodingContainerProtocol {
    typealias Key = K
    
    /// A reference to the decoder we're reading from.
    let decoder: _JSONDecoder
    
    /// A reference to the container we're reading from.
    let container: [String: JSON]
    
    /// The path of coding keys taken to get to this point in decoding.
    var codingPath: [CodingKey?]
    
    /// Initializes `self` by referencing the given decoder and container.
    init(referencing decoder: _JSONDecoder, wrapping container: [String: JSON]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
    }
    
    var allKeys: [Key] {
        return self.container.keys.flatMap { Key(stringValue: $0) }
    }
    
    func contains(_ key: Key) -> Bool {
        return self.container[key.stringValue] != nil
    }
    
    func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: Bool.self)
        }
    }
    
    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: Int.self)
        }
    }
    
    func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: Int8.self)
        }
    }
    
    func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: Int16.self)
        }
    }
    
    func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: Int32.self)
        }
    }
    
    func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: Int64.self)
        }
    }
    
    func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: UInt.self)
        }
    }
    
    func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: UInt8.self)
        }
    }
    
    func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: UInt16.self)
        }
    }
    
    func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: UInt32.self)
        }
    }
    
    func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: UInt64.self)
        }
    }
    
    func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: Float.self)
        }
    }
    
    func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: Double.self)
        }
    }
    
    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: String.self)
        }
    }
    
    func decodeIfPresent(_ type: Data.Type, forKey key: Key) throws -> Data? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: Data.self)
        }
    }
    
    func decodeIfPresent<T : Decodable>(_ type: T.Type, forKey key: Key) throws -> T? {
        return try self.decoder.with(pushedKey: key) {
            return try self.decoder.unbox(self.container[key.stringValue], as: T.self)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        return try self.decoder.with(pushedKey: key) {
            guard let value = self.container[key.stringValue] else {
                let context = DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \"\(key.stringValue)\""
                )
                
                throw DecodingError.keyNotFound(key, context)
            }
            
            guard case let .object(object) = value else {
                throw DecodingError._typeMismatch(
                    at: self.codingPath,
                    expectation: [String : Any].self,
                    reality: value
                )
            }
            
            let container = _JSONKeyedDecodingContainer<NestedKey>(
                referencing: self.decoder,
                wrapping: object
            )
            
            return KeyedDecodingContainer(container)
        }
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        return try self.decoder.with(pushedKey: key) {
            guard let value = self.container[key.stringValue] else {
                let context = DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \"\(key.stringValue)\""
                )
                
                throw DecodingError.keyNotFound(key, context)
            }
            
            guard case let .array(array) = value else {
                throw DecodingError._typeMismatch(
                    at: self.codingPath,
                    expectation: [Any].self,
                    reality: value
                )
            }
            
            return _JSONUnkeyedDecodingContainer(
                referencing: self.decoder,
                wrapping: array
            )
        }
    }
    
    func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        return try self.decoder.with(pushedKey: key) {
            guard let value = self.container[key.stringValue] else {
                throw DecodingError.keyNotFound(key,
                                                DecodingError.Context(codingPath: self.codingPath,
                                                                      debugDescription: "Cannot get superDecoder() -- no value found for key \"\(key.stringValue)\""))
            }
            
            return _JSONDecoder(
                referencing: value,
                at: self.decoder.codingPath,
                options: self.decoder.options
            )
        }
    }
    
    func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: _JSONSuperKey.super)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}

fileprivate struct _JSONUnkeyedDecodingContainer : UnkeyedDecodingContainer {
    /// A reference to the decoder we're reading from.
    let decoder: _JSONDecoder
    
    /// A reference to the container we're reading from.
    let container: [JSON]
    
    /// The path of coding keys taken to get to this point in decoding.
    var codingPath: [CodingKey?]
    
    /// The index of the element we're about to decode.
    var currentIndex: Int
    
    /// Initializes `self` by referencing the given decoder and container.
    init(referencing decoder: _JSONDecoder, wrapping container: [JSON]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
        self.currentIndex = 0
    }
    
    var count: Int? {
        return self.container.count
    }
    
    var isAtEnd: Bool {
        return self.currentIndex >= self.count!
    }
    
    mutating func decodeIfPresent(_ type: Bool.Type) throws -> Bool? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Bool.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: Int.Type) throws -> Int? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: Int8.Type) throws -> Int8? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int8.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: Int16.Type) throws -> Int16? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int16.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: Int32.Type) throws -> Int32? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int32.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: Int64.Type) throws -> Int64? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int64.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: UInt.Type) throws -> UInt? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: UInt8.Type) throws -> UInt8? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt8.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: UInt16.Type) throws -> UInt16? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt16.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: UInt32.Type) throws -> UInt32? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt32.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: UInt64.Type) throws -> UInt64? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt64.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: Float.Type) throws -> Float? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Float.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: Double.Type) throws -> Double? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Double.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: String.Type) throws -> String? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: String.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent(_ type: Data.Type) throws -> Data? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Data.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func decodeIfPresent<T : Decodable>(_ type: T.Type) throws -> T? {
        guard !self.isAtEnd else { return nil }
        
        return try self.decoder.with(pushedKey: nil) {
            let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: T.self)
            self.currentIndex += 1
            return decoded
        }
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        return try self.decoder.with(pushedKey: nil) {
            guard !self.isAtEnd else {
                let context = DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
                )
                
                throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self, context)
            }
            
            let value = self.container[self.currentIndex]
            
            guard !value.isNull else {
                let context = DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get keyed decoding container -- found null value instead."
                )
                
                throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self, context)
            }
            
            guard case let .object(object) = value else {
                throw DecodingError._typeMismatch(
                    at: self.codingPath,
                    expectation: [String : Any].self,
                    reality: value
                )
            }
            
            self.currentIndex += 1
            
            let container = _JSONKeyedDecodingContainer<NestedKey>(
                referencing: self.decoder,
                wrapping: object
            )
            
            return KeyedDecodingContainer(container)
        }
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try self.decoder.with(pushedKey: nil) {
            guard !self.isAtEnd else {
                let context = DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
                )
                
                throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
            }
            
            let value = self.container[self.currentIndex]
            
            guard !value.isNull else {
                let context = DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get keyed decoding container -- found null value instead."
                )
                
                throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
            }
            
            guard case let .array(array) = value else {
                throw DecodingError._typeMismatch(
                    at: self.codingPath,
                    expectation: [Any].self,
                    reality: value
                )
            }
            
            self.currentIndex += 1
            
            return _JSONUnkeyedDecodingContainer(
                referencing: self.decoder,
                wrapping: array
            )
        }
    }
    
    mutating func superDecoder() throws -> Decoder {
        return try self.decoder.with(pushedKey: nil) {
            guard !self.isAtEnd else {
                let context = DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."
                )
                
                throw DecodingError.valueNotFound(Decoder.self, context)
            }
            
            let value = self.container[self.currentIndex]
            
            guard !value.isNull else {
                let context = DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Cannot get superDecoder() -- found null value instead."
                )
                
                throw DecodingError.valueNotFound(Decoder.self, context)
            }
            
            self.currentIndex += 1
            
            return _JSONDecoder(
                referencing: value,
                at: self.decoder.codingPath,
                options: self.decoder.options
            )
        }
    }
}

extension _JSONDecoder : SingleValueDecodingContainer {
    func decodeNil() -> Bool {
        return self.storage.topContainer.isNull
    }
    
    // These all unwrap the result, since we couldn't have gotten a single value container if the topContainer was null.
    func decode(_ type: Bool.Type) throws -> Bool {
        guard let value = try self.unbox(self.storage.topContainer, as: Bool.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected Bool but found null value instead."
            )
            
            throw DecodingError.valueNotFound(Bool.self, context)
        }
        
        return value
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        guard let value = try self.unbox(self.storage.topContainer, as: Int.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected Int but found null value instead."
            )
            
            throw DecodingError.valueNotFound(Int.self, context)
        }
        
        return value
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        guard let value = try self.unbox(self.storage.topContainer, as: Int8.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected Int8 but found null value instead."
            )
            
            throw DecodingError.valueNotFound(Int8.self, context)
        }
        
        return value
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        guard let value = try self.unbox(self.storage.topContainer, as: Int16.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected Int16 but found null value instead."
            )
            
            throw DecodingError.valueNotFound(Int16.self, context)
        }
        
        return value
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        guard let value = try self.unbox(self.storage.topContainer, as: Int32.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected Int32 but found null value instead."
            )
            
            throw DecodingError.valueNotFound(Int32.self, context)
        }
        
        return value
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        guard let value = try self.unbox(self.storage.topContainer, as: Int64.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected Int64 but found null value instead."
            )
            
            throw DecodingError.valueNotFound(Int64.self, context)
        }
        
        return value
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        guard let value = try self.unbox(self.storage.topContainer, as: UInt.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected UInt but found null value instead."
            )
            
            throw DecodingError.valueNotFound(UInt.self, context)
        }
        
        return value
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard let value = try self.unbox(self.storage.topContainer, as: UInt8.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected UInt8 but found null value instead."
            )
            
            throw DecodingError.valueNotFound(UInt8.self, context)
        }
        
        return value
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard let value = try self.unbox(self.storage.topContainer, as: UInt16.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected UInt16 but found null value instead."
            )
            
            throw DecodingError.valueNotFound(UInt16.self, context)
        }
        
        return value
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard let value = try self.unbox(self.storage.topContainer, as: UInt32.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected UInt32 but found null value instead."
            )
            
            throw DecodingError.valueNotFound(UInt32.self, context)
        }
        
        return value
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard let value = try self.unbox(self.storage.topContainer, as: UInt64.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected UInt64 but found null value instead."
            )
            
            throw DecodingError.valueNotFound(UInt64.self, context)
        }
        
        return value
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        guard let value = try self.unbox(self.storage.topContainer, as: Float.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected Float but found null value instead."
            )
            
            throw DecodingError.valueNotFound(Float.self, context)
        }
        
        return value
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        guard let value = try self.unbox(self.storage.topContainer, as: Double.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected Double but found null value instead."
            )
            
            throw DecodingError.valueNotFound(Double.self, context)
        }
        
        return value
    }
    
    func decode(_ type: String.Type) throws -> String {
        guard let value = try self.unbox(self.storage.topContainer, as: String.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected String but found null value instead."
            )
            
            throw DecodingError.valueNotFound(String.self, context)
        }
        
        return value
    }
    
    func decode<T : Decodable>(_ type: T.Type) throws -> T {
        guard let value = try self.unbox(self.storage.topContainer, as: T.self) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected \(T.self) but found null value instead."
            )
            
            throw DecodingError.valueNotFound(T.self, context)
        }
        
        return value
    }
}

extension _JSONDecoder {
    /// Returns the given value unboxed from a container.
    fileprivate func unbox(_ value: JSON?, as type: Bool.Type) throws -> Bool? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        guard case let .bool(bool) = value else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }
        
        return bool
    }
    
    fileprivate func unbox(_ value: JSON?, as type: Int.Type) throws -> Int? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        guard case let .int(int) = value else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }
        
        return int
    }
    
    fileprivate func unbox(_ value: JSON?, as type: Int8.Type) throws -> Int8? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        guard case let .int(int) = value else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }
        
        guard let int8 = Int8(exactly: int) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Parsed JSON number <\(int)> does not fit in \(type)."
            )
            
            throw DecodingError.dataCorrupted(context)
        }
        
        return int8
    }
    
    fileprivate func unbox(_ value: JSON?, as type: Int16.Type) throws -> Int16? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        guard case let .int(int) = value else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }
        
        guard let int16 = Int16(exactly: int) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Parsed JSON number <\(int)> does not fit in \(type)."
            )
            
            throw DecodingError.dataCorrupted(context)
        }
        
        return int16
    }
    
    fileprivate func unbox(_ value: JSON?, as type: Int32.Type) throws -> Int32? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        guard case let .int(int) = value else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }
        
        guard let int32 = Int32(exactly: int) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Parsed JSON number <\(int)> does not fit in \(type)."
            )
            
            throw DecodingError.dataCorrupted(context)
        }
        
        return int32
    }
    
    fileprivate func unbox(_ value: JSON?, as type: Int64.Type) throws -> Int64? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        guard case let .int(int) = value else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }
        
        guard let int64 = Int64(exactly: int) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Parsed JSON number <\(int)> does not fit in \(type)."
            )
            
            throw DecodingError.dataCorrupted(context)
        }
        
        return int64
    }
    
    fileprivate func unbox(_ value: JSON?, as type: UInt.Type) throws -> UInt? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        guard case let .int(int) = value else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }
        
        guard let uint = UInt(exactly: int) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Parsed JSON number <\(int)> does not fit in \(type)."
            )
            
            throw DecodingError.dataCorrupted(context)
        }
        
        return uint
    }
    
    fileprivate func unbox(_ value: JSON?, as type: UInt8.Type) throws -> UInt8? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        guard case let .int(int) = value else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }
        
        guard let uint8 = UInt8(exactly: int) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Parsed JSON number <\(int)> does not fit in \(type)."
            )
            
            throw DecodingError.dataCorrupted(context)
        }
        
        return uint8
    }
    
    fileprivate func unbox(_ value: JSON?, as type: UInt16.Type) throws -> UInt16? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        guard case let .int(int) = value else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }
        
        guard let uint16 = UInt16(exactly: int) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Parsed JSON number <\(int)> does not fit in \(type)."
            )
            
            throw DecodingError.dataCorrupted(context)
        }
        
        return uint16
    }
    
    fileprivate func unbox(_ value: JSON?, as type: UInt32.Type) throws -> UInt32? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        guard case let .int(int) = value else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }
        
        guard let uint32 = UInt32(exactly: int) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Parsed JSON number <\(int)> does not fit in \(type)."
            )
            
            throw DecodingError.dataCorrupted(context)
        }
        
        return uint32
    }
    
    fileprivate func unbox(_ value: JSON?, as type: UInt64.Type) throws -> UInt64? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        guard case let .int(int) = value else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }
        
        guard let uint64 = UInt64(exactly: int) else {
            let context = DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Parsed JSON number <\(int)> does not fit in \(type)."
            )
            
            throw DecodingError.dataCorrupted(context)
        }
        
        return uint64
    }
    
    fileprivate func unbox(_ value: JSON?, as type: Float.Type) throws -> Float? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        if case let .double(double) = value {
            guard let float = Float(exactly: double) else {
                let context = DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Parsed JSON number \(double) does not fit in \(type)."
                )
                
                throw DecodingError.dataCorrupted(context)
            }
            
            return float
        } else if case let .string(string) = value, case .convertFromString(
            let posInfString,
            let negInfString,
            let nanString
        ) = self.options.nonConformingFloatDecodingStrategy {
            if string == posInfString {
                return Float.infinity
            } else if string == negInfString {
                return -Float.infinity
            } else if string == nanString {
                return Float.nan
            }
        }
        
        throw DecodingError._typeMismatch(
            at: self.codingPath,
            expectation: type,
            reality: value
        )
    }
    
    func unbox(_ value: JSON?, as type: Double.Type) throws -> Double? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        if case let .double(double) = value {
            return double
        } else if case let .string(string) = value, case .convertFromString(
            let posInfString,
            let negInfString,
            let nanString
        ) = self.options.nonConformingFloatDecodingStrategy {
            if string == posInfString {
                return Double.infinity
            } else if string == negInfString {
                return -Double.infinity
            } else if string == nanString {
                return Double.nan
            }
        }
        
        throw DecodingError._typeMismatch(
            at: self.codingPath,
            expectation: type,
            reality: value
        )
    }
    
    func unbox(_ value: JSON?, as type: String.Type) throws -> String? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        guard case let .string(string) = value else {
            throw DecodingError._typeMismatch(
                at: self.codingPath,
                expectation: type,
                reality: value
            )
        }
        
        return string
    }
    
    func unbox(_ value: JSON?, as type: Date.Type) throws -> Date? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        switch self.options.dateDecodingStrategy {
        case .deferredToDate:
            self.storage.push(container: value)
            let date = try Date(from: self)
            self.storage.popContainer()
            return date
            
        case .secondsSince1970:
            let double = try self.unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double)
            
        case .millisecondsSince1970:
            let double = try self.unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double / 1000.0)
            
        case .iso8601:
            if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                let string = try self.unbox(value, as: String.self)!
                guard let date = _iso8601Formatter.date(from: string) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
                }
                
                return date
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
            
        case .formatted(let formatter):
            let string = try self.unbox(value, as: String.self)!
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date string does not match format expected by formatter."))
            }
            
            return date
            
        case .custom(let closure):
            self.storage.push(container: value)
            let date = try closure(self)
            self.storage.popContainer()
            return date
        }
    }
    
    func unbox(_ value: JSON?, as type: Data.Type) throws -> Data? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        switch self.options.dataDecodingStrategy {
        case .base64Decode:
            guard case let .string(string) = value else {
                throw DecodingError._typeMismatch(
                    at: self.codingPath,
                    expectation: type,
                    reality: value
                )
            }
            
            guard let data = Data(base64Encoded: string) else {
                let context = DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Encountered Data is not valid Base64."
                )
                
                throw DecodingError.dataCorrupted(context)
            }
            
            return data
            
        case .custom(let closure):
            self.storage.push(container: value)
            let data = try closure(self)
            self.storage.popContainer()
            return data
        }
    }
    
    func unbox<T : Decodable>(_ value: JSON?, as type: T.Type) throws -> T? {
        guard let value = value else {
            return nil
        }
        
        guard !value.isNull else {
            return nil
        }
        
        let decoded: T
        if T.self == Date.self {
            decoded = (try self.unbox(value, as: Date.self) as! T)
        } else if T.self == Data.self {
            decoded = (try self.unbox(value, as: Data.self) as! T)
        } else if T.self == URL.self {
            guard let urlString = try self.unbox(value, as: String.self) else {
                return nil
            }
            
            guard let url = URL(string: urlString) else {
                let context = DecodingError.Context(
                    codingPath: self.codingPath,
                    debugDescription: "Invalid URL string."
                )
                
                throw DecodingError.dataCorrupted(context)
            }
            
            decoded = (url as! T)
        } else {
            self.storage.push(container: value)
            decoded = try T(from: self)
            self.storage.popContainer()
        }
        
        return decoded
    }
}
