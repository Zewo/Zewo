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

import Incandescence

public struct URIUserInfo {
    public let username: String
    public let password: String
}

public struct URI {
    public let scheme: String?
    public let userInfo: URIUserInfo?
    public let host: String?
    public let port: Int?
    public let path: String?
    public let query: [String: String]
    public let fragment: String?

}

extension URI {
    init() {
        self.scheme = nil
        self.userInfo = nil
        self.host = nil
        self.port = nil
        self.path = nil
        self.query = [:]
        self.fragment = nil
    }
}

extension URI {
    init(uri: parsed_uri) {
        self.scheme        = String.fromCString(uri.scheme)
        let userInfoString = String.fromCString(uri.user_info)
        self.userInfo      = URI.parseUserInfo(userInfoString)
        self.host          = String.fromCString(uri.host)
        self.port          = (uri.port != nil) ? Int(uri.port.memory) : nil
        self.path          = String.fromCString(uri.path)
        let queryString    = String.fromCString(uri.query)
        self.query         = URI.parseQueryString(queryString)
        self.fragment      = String.fromCString(uri.fragment)
    }

    private static func parseUserInfo(userInfoString: String?) -> URIUserInfo? {
        guard let userInfoString = userInfoString else {
            return nil
        }
        let userInfoElements = userInfoString.characters.split{$0 == ":"}.map(String.init)
        return URIUserInfo(
            username: userInfoElements[0],
            password: userInfoElements[1]
        )
    }

    private static func parseQueryString(queryString: String?) -> [String: String] {
        guard let queryString = queryString else {
            return [:]
        }
        var query: [String: String] = [:]
        let queryTuples = queryString.characters.split{$0 == "&"}.map(String.init)
        for tuple in queryTuples {
            let queryElements = tuple.characters.split{$0 == "="}.map(String.init)
            if queryElements.count == 1 {
                query[queryElements[0]] = ""
            } else if queryElements.count == 2 {
                query[queryElements[0]] = queryElements[1]
            }
        }
        return query
    }
}

extension URI {
    public init(string: String) {
        let parsedURI = parse_uri(string)
        self = URI(uri: parsedURI)
        free_parsed_uri(parsedURI)
    }
}