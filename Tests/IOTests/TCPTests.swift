import XCTest
@testable import IO
@testable import Core
@testable import Venice

let deadline: Deadline = .never

public class TCPTests: XCTestCase {
    func testConnectionRefused() throws {
        let deadline = 1.minute.fromNow()
        let connection = try TCPStream(host: "127.0.0.1", port: 1111, deadline: deadline)
        XCTAssertThrowsError(try connection.open(deadline: deadline))
    }

    func testWriteClosedSocket() throws {
        let deadline = 1.minute.fromNow()
        let port = 2222
        let channel = try Channel<Void>()

        let coroutine = try Coroutine {
            do {
                let host = try TCPHost(port: port)
                let stream = try host.accept(deadline: deadline)
                try channel.receive(deadline: deadline)
                try stream.close()
                XCTAssertThrowsError(try stream.write("123", deadline: deadline))
                try channel.send(deadline: deadline)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }

        let stream = try TCPStream(host: "127.0.0.1", port: port, deadline: deadline)
        try stream.open(deadline: deadline)
        try channel.send(deadline: deadline)
        try stream.close()
        XCTAssertThrowsError(try stream.write("123", deadline: deadline))
        try channel.receive(deadline: deadline)
        try coroutine.close()
    }

    func testReadClosedSocket() throws {
        let deadline = 1.minute.fromNow()
        let port = 4444
        let channel = try Channel<Void>()
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 1)
        
        defer {
            buffer.deallocate()
        }
        
        let coroutine = try Coroutine {
            do {
                let host = try TCPHost(port: port)
                let stream = try host.accept(deadline: deadline)
                try channel.receive(deadline: deadline)
                try stream.close()
                XCTAssertThrowsError(try stream.read(buffer, deadline: deadline))
                try channel.send(deadline: deadline)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        let stream = try TCPStream(host: "127.0.0.1", port: port, deadline: deadline)
        try stream.open(deadline: deadline)
        try channel.send(deadline: deadline)
        try stream.close()
        XCTAssertThrowsError(try stream.read(buffer, deadline: deadline))
        try channel.receive(deadline: deadline)
        try coroutine.close()

    }

    func testClientServer() throws {
        let deadline = 1.minute.fromNow()
        let port = 6666
        let channel = try Channel<Void>()
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: 10)
        
        defer {
            buffer.deallocate()
        }
        
        let coroutine = try Coroutine {
            do {
                let host = try TCPHost(port: port)
                let stream = try host.accept(deadline: deadline)
                try stream.write("Yo client!", deadline: deadline)
                let readBuffer = try stream.read(buffer, deadline: deadline)
                XCTAssertEqual(String(data: Data(readBuffer), encoding: .utf8), "Yo server!")
                try channel.send(deadline: deadline)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }

        let stream = try TCPStream(host: "127.0.0.1", port: port, deadline: deadline)
        try stream.open(deadline: deadline)
        let readBuffer = try stream.read(buffer, deadline: deadline)
        XCTAssertEqual(String(data: Data(readBuffer), encoding: .utf8), "Yo client!")
        try stream.write("Yo server!", deadline: deadline)
        try channel.receive(deadline: deadline)
        try coroutine.close()
    }
}

extension TCPTests {
    public static var allTests: [(String, (TCPTests) -> () throws -> Void)] {
        return [
            ("testConnectionRefused", testConnectionRefused),
            ("testWriteClosedSocket", testWriteClosedSocket),
            ("testReadClosedSocket", testReadClosedSocket),
            ("testClientServer", testClientServer),
        ]
    }
}
