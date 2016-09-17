// StructuredData.swift
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

extension StructuredData {
    internal var mapper: Mapper {
        return Mapper(structuredData: self)
    }
}

extension StructuredData {
    internal func mapThrough<T>(_ transform: (@noescape (StructuredData) throws -> T)) throws -> [T] {
        if let array = self.arrayValue {
            return try array.map(transform)
        }
        throw StructuredData.Error.incompatibleType
    }
    
    internal func mapThrough<T>(_ key: String, transform: (@noescape (StructuredData) throws -> T)) throws -> [T] {
        if let value = self[key] {
            return try value.mapThrough(transform)
        }
        throw StructuredData.Error.incompatibleType
    }
    
//    internal func mapThrough<T>(index: Int, @noescape transform: (StructuredData throws -> T)) throws -> [T] {
//        if let value = self[index] {
//            return try value.mapThrough(transform)
//        }
//        throw StructuredData.Error.incompatibleType
//    }
    
    internal func flatMapThrough<T>(_ transform: (@noescape (StructuredData) throws -> T?)) throws -> [T] {
        if let array = self.arrayValue {
            return try array.flatMap(transform)
        }
        throw StructuredData.Error.incompatibleType
    }
    
    internal func flatMapThrough<T>(_ key: String, transform: (@noescape (StructuredData) throws -> T?)) throws -> [T] {
        if let value = self[key] {
            return try value.flatMapThrough(transform)
        }
        throw StructuredData.Error.incompatibleType
    }
    
}
