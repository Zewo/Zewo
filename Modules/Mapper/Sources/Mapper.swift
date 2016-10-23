// Mapper.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2016 Oleg Dreyman
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@_exported import StructuredData

// MARK: - Main
public final class Mapper {
    public enum Error: ErrorProtocol {
        case cantInitFromRawValue
        case noStrutcuredData(key: String)
        case incompatibleSequence
    }
    
    public init(structuredData: StructuredData) {
        self.structuredData = structuredData
    }
    
    public let structuredData: StructuredData
}

// MARK: - General case

extension Mapper {
    public func map<T>(from key: String) throws -> T {
        let value: T = try structuredData.get(key)
        return value
    }
    
    public func map<T: StructuredDataInitializable>(from key: String) throws -> T {
        if let nested = structuredData[key] {
            return try unwrap(T(structuredData: nested))
        }
        throw Error.noStrutcuredData(key: key)
    }
    
    public func map<T: RawRepresentable where T.RawValue: StructuredDataInitializable>(from key: String) throws -> T {
        guard let rawValue = try structuredData[key].flatMap({ try T.RawValue(structuredData: $0) }) else {
            throw Error.cantInitFromRawValue
        }
        if let value = T(rawValue: rawValue) {
            return value
        }
        throw Error.cantInitFromRawValue
    }
}

// MARK: - Arrays

extension Mapper {
    
    public func map<T>(arrayFrom key: String) throws -> [T] {
        return try structuredData.mapThrough(key) { try $0.get() as T }
    }
    
    public func map<T where T: StructuredDataInitializable>(arrayFrom key: String) throws -> [T] {
        return try structuredData.mapThrough(key) { try T(structuredData: $0) }
    }
    
    public func map<T: RawRepresentable where
                    T.RawValue: StructuredDataInitializable>(arrayFrom key: String) throws -> [T] {
        return try structuredData.mapThrough(key) {
  					guard let value = T(rawValue: try T.RawValue(structuredData: $0)) else {
              throw Error.cantInitFromRawValue
  					}
  					
  					return value
        }
    }
}

// MARK: - Optionals

extension Mapper {
    
    public func map<T>(optionalFrom key: String) -> T? {
        do {
            return try map(from: key)
        } catch {
            return nil
        }
    }
    
    public func map<T: StructuredDataInitializable>(optionalFrom key: String) -> T? {
        if let nested = structuredData[key] {
            return try? T(structuredData: nested)
        }
        return nil
    }
    
    public func map<T: RawRepresentable where T.RawValue: StructuredDataInitializable>(optionalFrom key: String) -> T? {
        do {
            if let rawValue = try structuredData[key].flatMap({ try T.RawValue(structuredData: $0) }),
                value = T(rawValue: rawValue) {
                return value
            }
            return nil
        } catch {
            return nil
        }
    }
}

// MARK: - Optional arrays

extension Mapper {
    
    public func map<T>(optionalArrayFrom key: String) -> [T]? {
        return try? structuredData.flatMapThrough(key) { try $0.get() as T }
    }
    
    public func map<T where T: StructuredDataInitializable>(optionalArrayFrom key: String) -> [T]? {
        return try?  structuredData.flatMapThrough(key) { try? T(structuredData: $0) }
    }
    
    public func map<T: RawRepresentable where
                    T.RawValue: StructuredDataInitializable>(optionalArrayFrom key: String) -> [T]? {
        return try? structuredData.flatMapThrough(key) {
            return (try? T.RawValue(structuredData: $0)).flatMap({ T(rawValue: $0) })
        }
    }
}

// MARK: - Unwrap

public enum UnwrapError: ErrorProtocol {
    case tryingToUnwrapNil
}

extension Mapper {
    private func unwrap<T>(_ optional: T?) throws -> T {
        if let nonoptional = optional {
            return nonoptional
        }
        throw UnwrapError.tryingToUnwrapNil
    }
}