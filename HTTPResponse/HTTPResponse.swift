// HTTPResponse.swift
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

public struct HTTPResponse {
    public let statusCode: Int
    public let reasonPhrase: String
    public let majorVersion: Int
    public let minorVersion: Int
    public let headers: [String: String]
    public let body: [Int8]

    public init(statusCode: Int, reasonPhrase: String, majorVersion: Int = 1, minorVersion: Int = 1, var headers: [String: String] = [:], body: [Int8] = []) {
        self.statusCode = statusCode
        self.reasonPhrase = reasonPhrase
        self.majorVersion = majorVersion
        self.minorVersion = minorVersion

        if body.count > 0 {
            headers["content-length"] = "\(body.count)"
        }
        
        self.headers = headers
        self.body = body
    }
}

extension HTTPResponse {
    public init(status: HTTPStatus, headers: [String: String] = [:], body: [Int8] = []) {
        self.init(
            statusCode: status.statusCode,
            reasonPhrase: status.reasonPhrase,
            headers: headers,
            body: body
        )
    }

    public var status: HTTPStatus {
        return HTTPStatus(statusCode: statusCode)
    }
}

extension HTTPResponse {
    public init(status: HTTPStatus, headers: [String: String] = [:], body: String) {
        self.init(
            status: status,
            headers: headers,
            body: body.utf8.map({Int8($0)})
        )
    }

    var bodyString: String? {
        return String.fromCString(body + [0])
    }

    var bodyHexString: String {
        var string = ""
        for (index, value) in body.enumerate() {
            if index % 2 == 0 && index > 0 {
                string += " "
            }
            string += (value < 16 ? "0" : "") + String(value, radix: 16)
        }
        return string
    }
}

extension HTTPResponse : CustomStringConvertible {
    public var description: String {
        var string = "HTTP/1.1 \(statusCode) \(reasonPhrase)\n"

        for (header, value) in headers {
            string += "\(header): \(value)\n"
        }

        if body.count > 0 {
            if let bodyString = bodyString {
                string += "\n" + bodyString
            } else  {
                string += "\n" + bodyHexString
            }
        }

        return string
    }
}
