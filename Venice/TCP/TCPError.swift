// TCPError.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
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

import libmill

public enum TCPError : ErrorType {
    case Generic(description: String)
    case ConnectionResetByPeer(description: String, remainingData: [Int8])
    case NoBufferSpaceAvailabe(description: String, receivedData: [Int8])

    static func lastErrorWithData(data: [Int8], bytesProcessed: Int) -> TCPError {
        let description = String.fromCString(strerror(errno))!
        switch errno {
        case ECONNRESET:
            let remainingData = remainingDataFromSource(data, bytesProcessed: bytesProcessed)
            return .ConnectionResetByPeer(description: description, remainingData: remainingData)
        case ENOBUFS:
            let receivedData = processedDataFromSource(data, bytesProcessed: bytesProcessed)
            return .NoBufferSpaceAvailabe(description: description, receivedData: receivedData)
        default:
            return .Generic(description: description)
        }
    }

    static var lastError: TCPError {
        let description = String.fromCString(strerror(errno))!
        return .Generic(description: description)
    }
}
