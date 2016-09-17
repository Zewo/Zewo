import XCTest
@testable import HTTPServer

extension Server {
    init(host: Core.Host, responder: Responder) throws {
        self.tcpHost = host
        self.host = "127.0.0.1"
        self.port = 8080
        self.bufferSize = 2048
        self.middleware = []
        self.responder = responder
        self.failure = Server.log(error:)
    }
}

final class ServerStream : Core.Stream {
    var inputBuffer: Data
    var outputBuffer = Data()
    var closed = false
    let closeOnFlush: Bool

    init(_ inputBuffer: Data = Data(), closeOnFlush: Bool = false) {
        self.inputBuffer = inputBuffer
        self.closeOnFlush = closeOnFlush
    }

    func close() {
        closed = true
    }

    func read(into targetBuffer: inout Data, length: Int, deadline: Double = .never) throws -> Int {
        guard !closed && !inputBuffer.isEmpty else {
            throw StreamError.closedStream(data: Data())
        }

        if inputBuffer.isEmpty {
            return 0
        }

        if length >= inputBuffer.count {
            targetBuffer.replaceSubrange(0 ..< inputBuffer.count, with: inputBuffer)
            let read = inputBuffer.count
            inputBuffer = Data()
            close()
            return read
        }

        targetBuffer.replaceSubrange(0 ..< length, with: inputBuffer[0 ..< length])
        inputBuffer.removeFirst(length)

        return length
    }

    func write(_ data: Data, length: Int, deadline: Double = .never) throws -> Int {
        data.withUnsafeBytes {
            outputBuffer.append($0, count: length)
        }

        return length
    }
    
    func flush(deadline: Double = .never) throws {
        if closeOnFlush {
            close()
        }
    }
}

class TestHost : Core.Host {
    let data: Data
    let closeOnFlush: Bool

    init(data: Data, closeOnFlush: Bool = false) {
        self.data = data
        self.closeOnFlush = closeOnFlush
    }

    func accept(deadline: Double) throws -> Core.Stream {
        return ServerStream(data, closeOnFlush: closeOnFlush)
    }
}

enum CustomError :  Error {
    case error
}

public class ServerTests : XCTestCase {
    func testServer() throws {
        var called = false

        let responder = BasicResponder { request in
            called = true
            XCTAssertEqual(request.method, .get)
            return Response()
        }

        let server = try Server(
            host: TestHost(data: Data("GET / HTTP/1.1\r\n\r\n")),
            responder: responder
        )
        let stream = try server.tcpHost.accept()
        server.printHeader()
        try server.process(stream: stream)
        XCTAssert(try String(data: (stream as! ServerStream).outputBuffer).contains(substring: "OK"))
        XCTAssert(called)
    }

    func testServerRecover() throws {
        var called = false
        var stream: Core.Stream = ServerStream()

        let responder = BasicResponder { request in
            called = true
            (stream as! ServerStream).closed = false
            XCTAssertEqual(request.method, .get)
            throw HTTPError.badRequest
        }

        let server = try Server(
            host: TestHost(data: Data("GET / HTTP/1.1\r\n\r\n"), closeOnFlush: true),
            responder: responder
        )
        stream = try server.tcpHost.accept()
        try server.process(stream: stream)
        XCTAssert(try String(data: (stream as! ServerStream).outputBuffer).contains(substring: "Bad Request"))
        XCTAssert(called)
    }

    func testServerNoRecover() throws {
        var called = false
        var stream: Core.Stream = ServerStream()

        let responder = BasicResponder { request in
            called = true
            (stream as! ServerStream).closed = false
            XCTAssertEqual(request.method, .get)
            throw CustomError.error
        }

        let server = try Server(
            host: TestHost(data: Data("GET / HTTP/1.1\r\n\r\n")),
            responder: responder
        )
        stream = try server.tcpHost.accept()
        XCTAssertThrowsError(try server.process(stream: stream))
        XCTAssert(try String(data: (stream as! ServerStream).outputBuffer).contains(substring: "Internal Server Error"))
        XCTAssert(called)
    }

    func testBrokenPipe() throws {
        var called = false
        var stream: Core.Stream = ServerStream()

        let responder = BasicResponder { request in
            called = true
            (stream as! ServerStream).closed = false
            XCTAssertEqual(request.method, .get)
            throw SystemError.brokenPipe
        }

        let request = Data("GET / HTTP/1.1\r\n\r\n")

        let server = try Server(
            host: TestHost(data: request),
            responder: responder
        )
        stream = try server.tcpHost.accept()
        try server.process(stream: stream)
        XCTAssert(called)
    }

    func testNotKeepAlive() throws {
        var called = false
        var stream: Core.Stream = ServerStream()

        let responder = BasicResponder { request in
            called = true
            (stream as! ServerStream).closed = false
            XCTAssertEqual(request.method, .get)
            return Response()
        }

        let request = Data("GET / HTTP/1.1\r\nConnection: close\r\n\r\n")

        let server = try Server(
            host: TestHost(data: request),
            responder: responder
        )
        stream = try server.tcpHost.accept()
        try server.process(stream: stream)
        XCTAssert(try String(data: (stream as! ServerStream).outputBuffer).contains(substring: "OK"))
        XCTAssertTrue(stream.closed)
        XCTAssert(called)
    }

    func testUpgradeConnection() throws {
        var called = false
        var upgradeCalled = false
        var stream: Core.Stream = ServerStream()

        let responder = BasicResponder { request in
            called = true
            (stream as! ServerStream).closed = false
            XCTAssertEqual(request.method, .get)
            var response = Response()
            response.upgradeConnection { request, stream in
                XCTAssertEqual(request.method, .get)
                XCTAssert(try String(data: (stream as! ServerStream).outputBuffer).contains(substring: "OK"))
                XCTAssertFalse(stream.closed)
                upgradeCalled = true
            }
            return response
        }

        let request = Data("GET / HTTP/1.1\r\nConnection: close\r\n\r\n")

        let server = try Server(
            host: TestHost(data: request),
            responder: responder
        )
        stream = try server.tcpHost.accept()
        try server.process(stream: stream)
        XCTAssert(try String(data: (stream as! ServerStream).outputBuffer).contains(substring: "OK"))
        XCTAssertTrue(stream.closed)
        XCTAssert(called)
        XCTAssert(upgradeCalled)
    }

    func testLogError() {
        Server.log(error: HTTPError.badRequest)
    }
}

extension ServerTests {
    public static var allTests: [(String, (ServerTests) -> () throws -> Void)] {
        return [
            ("testServer", testServer),
            ("testServerRecover", testServerRecover),
            ("testServerNoRecover", testServerNoRecover),
            ("testBrokenPipe", testBrokenPipe),
            ("testNotKeepAlive", testNotKeepAlive),
            ("testUpgradeConnection", testUpgradeConnection),
            ("testLogError", testLogError),
        ]
    }
}
