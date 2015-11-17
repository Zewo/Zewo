// HTTPRequest.swift
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

public struct HTTPRequest {
    public let method: HTTPMethod
    public let uri: URI
    public let majorVersion: Int
    public let minorVersion: Int
    public let headers: [String: String]
    public let body: [Int8]

    public let keepAlive: Bool
    public var parameters: [String : String] = [:]
    public var data: [String : String] = [:]

    public init(method: HTTPMethod, uri: URI, majorVersion: Int = 1, minorVersion: Int = 1, headers: [String: String] = [:], body: [Int8] = [], keepAlive: Bool = false) {
        self.method = method
        self.uri = uri
        self.majorVersion = majorVersion
        self.minorVersion = minorVersion
        self.headers = headers
        self.body = body
        self.keepAlive = keepAlive
    }
}

extension HTTPRequest : CustomStringConvertible {
    public var description: String {
        var string = "\(method) \(uri) HTTP/1.1\n"

        for (header, value) in headers {
            string += "\(header): \(value)\n"
        }

        if body.count > 500 {
            string += "Request body too big to be printed."
        } else if body.count > 0 {
            if let bodyString = String.fromCString(self.body + [0]) where self.body.count > 0 {
                string += "\n" + bodyString + "\n"
            } else  {
                string += "\n" + body.reduce("", combine: {$0.0 + String($0.1)}) + "\n"
            }
        }

        return string
    }
}

