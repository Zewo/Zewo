import XCTest
@testable import TCP
@testable import Venice

public class TCPTests : XCTestCase {
    func testConnectionRefused() throws {
        let connection = try TCPConnection(host: "127.0.0.1", port: 1111)
        XCTAssertThrowsError(try connection.open())
    }

    func testSendClosedSocket() throws {
        let host = try TCPHost(configuration: [])

        co {
            do {
                let connection = try TCPConnection(host: "127.0.0.1", port: 8080)
                try connection.open()
                connection.close()
                XCTAssertThrowsError(try connection.write(Data(), deadline: .never))
            } catch {
                XCTFail()
            }
        }

        _ = try host.accept()
        nap(for: 1.millisecond)
    }

    func testFlushClosedSocket() throws {
        let port = 3333
        let host = try TCPHost(configuration: ["host": "127.0.0.1", "port": Map(port), "reusePort": true])

        co {
            do {
                let connection = try TCPConnection(host: "127.0.0.1", port: port)
                try connection.open()
                connection.close()
                XCTAssertThrowsError(try connection.flush())
            } catch {
                XCTFail()
            }
        }

        _ = try host.accept()
        nap(for: 1.millisecond)
    }

    func testReceiveClosedSocket() throws {
        let port = 4444
        let host = try TCPHost(configuration: ["host": "127.0.0.1", "port": Map(port), "reusePort": true])

        co {
            do {
                let connection = try TCPConnection(host: "127.0.0.1", port: port)
                try connection.open()
                connection.close()
                var buffer = Data(count: 1)
                XCTAssertThrowsError(try connection.read(into: &buffer))
            } catch {
                XCTFail()
            }
        }

        _ = try host.accept()
        nap(for: 1.millisecond)
    }

    func testSendReceive() throws {
        let port = 5555
        let host = try TCPHost(configuration: ["host": "127.0.0.1", "port": Map(port), "reusePort": true])

        co {
            do {
                let connection = try TCPConnection(host: "127.0.0.1", port: port)
                try connection.open()
                try connection.write(Data([123]))
                try connection.flush()
            } catch {
                XCTAssert(false)
            }
        }

        let connection = try host.accept()
        var buffer = Data(count: 1)
        let bytesRead = try connection.read(into: &buffer)
        XCTAssertEqual(bytesRead, 1)
        XCTAssertEqual(buffer, Data([123]))
        connection.close()
    }

    func testClientServer() throws {
        let port = 6666
        let host = try TCPHost(configuration: ["host": "127.0.0.1", "port": Map(port), "reusePort": true])

        co {
            do {
                let connection = try TCPConnection(host: "127.0.0.1", port: port)
                try connection.open()

                var buffer = Data(count: 3)
                let bytesRead = try connection.read(into: &buffer)
                XCTAssertEqual(buffer, Data("ABC"))
                XCTAssertEqual(bytesRead, 3)

                try connection.write("123456789")
                try connection.flush()
            } catch {
                XCTFail()
            }
        }

        let connection = try host.accept()
        let deadline = 30.milliseconds.fromNow()

        var buffer = Data(count: 16)
        XCTAssertThrowsError(try connection.read(into: &buffer, deadline: deadline))

        let diff = now() - deadline
        XCTAssert(diff > -300 && diff < 300)

        try connection.write("ABC")
        try connection.flush()

        buffer = Data(count: 9)
        let bytesRead = try connection.read(into: &buffer)
        XCTAssertEqual(bytesRead, 9)
        XCTAssertEqual(buffer, Data("123456789"))
    }
}

extension TCPTests {
    public static var allTests: [(String, (TCPTests) -> () throws -> Void)] {
        return [
            ("testConnectionRefused", testConnectionRefused),
            ("testSendClosedSocket", testSendClosedSocket),
            ("testFlushClosedSocket", testFlushClosedSocket),
            ("testReceiveClosedSocket", testReceiveClosedSocket),
            ("testSendReceive", testSendReceive),
            ("testClientServer", testClientServer),
        ]
    }
}
