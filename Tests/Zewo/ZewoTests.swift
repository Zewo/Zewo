// MessageTests.swift
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

@testable import Zewo
import XCTest

class ZewoTests: XCTestCase {
    func testBufferStream() {
        let stream = ChannelStream { stream in
            try stream.send("y")
            try stream.send("o")
            try stream.send(" ")
            try stream.send("m")
            try stream.send("a")
            try stream.send("n")
            try stream.send("!")
        }

        var request = Request()
        request.body = stream
        var count = 0
        for _ in StreamSequence(request.body) {
            count += 1
        }
        XCTAssertEqual(count, 7)
        for _ in StreamSequence(request.body) {
            XCTFail()
        }
        XCTAssert(request.buffer.isEmpty)
        for _ in StreamSequence(request.body) {
            XCTFail()
        }
        XCTAssert(request.buffer.isEmpty)
        for _ in StreamSequence(request.body) {
            XCTFail()
        }
        request.buffer = "yeah man"
        count = 0
        for data in StreamSequence(request.body) {
            count += 1
            XCTAssertEqual(data, "yeah man")
        }
        XCTAssertEqual(count, 1)
        XCTAssert(request.buffer.isEmpty)
        request.buffer = "hey"
        XCTAssertEqual(request.buffer, "hey")
        XCTAssertEqual(request.buffer, "hey")
        request.buffer += " babe"
        XCTAssertEqual(request.buffer, "hey babe")
        count = 0
        for data in StreamSequence(request.body) {
            count += 1
            XCTAssertEqual(data, "hey babe")
        }
        XCTAssertEqual(count, 1)
    }
}

extension ZewoTests {
    static var allTests: [(String, ZewoTests -> () throws -> Void)] {
        return [
            ("testBufferStream", testBufferStream),
        ]
    }
}