// URI.swift
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

public struct URI {
    public struct UserInfo {
        public let username: String
        public let password: String
    }

    public let scheme: String?
    public let userInfo: UserInfo?
    public let host: String?
    public let port: Int?
    public let path: String?
    public let query: [String : String]
    public let fragment: String?
}

extension URI : CustomStringConvertible {
    public var description: String {
        var string = ""

        if let scheme = scheme {
            string += "\(scheme)://"
        }

        if let userInfo = userInfo {
            string += "\(userInfo.username):\(userInfo.password)@"
        }

        if let host = host {
            string += "\(host)"
        }

        if let port = port {
            string += ":\(port)"
        }

        if let path = path {
            string += "\(path)"
        }

        if query.count > 0 {
            string += "?"
        }

        for (name, value) in query {
            string += "\(name)=\(value)"
        }

        if let fragment = fragment {
            string += "#\(fragment)"
        }

        return string
    }
}
