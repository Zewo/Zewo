import XCTest
@testable import IP

public class IPTests : XCTestCase {
    func testErrorDescription() {
        XCTAssertEqual(String(describing: IPError.invalidPort), "Port number should be between 0 and 0xffff")
    }

    func testIPV4() throws {
        _ = try IP(port: 5555, mode: .ipV4)
    }

    func testIPV6() throws {
        _ = try IP(port: 5555, mode: .ipV6)
    }

    func testIPV4Prefered() throws {
        _ = try IP(port: 5555, mode: .ipV4Prefered)
    }

    func testIPV6Prefered() throws {
        _ = try IP(port: 5555, mode: .ipV6Prefered)
    }

    func testLocalIPV4() throws {
        _ = try IP(localAddress: "127.0.0.1", port: 5555, mode: .ipV4)
    }

    func testLocalIPV6() throws {
        _ = try IP(localAddress: "::1", port: 5555, mode: .ipV6)
    }

    func testLocalIPV4Prefered() throws {
        _ = try IP(localAddress: "127.0.0.1", port: 5555, mode: .ipV4Prefered)
    }

    func testLocalIPV6Prefered() throws {
        _ = try IP(localAddress: "::1", port: 5555, mode: .ipV6Prefered)
    }

    func testRemoteIPV4() throws {
        let ip = try IP(remoteAddress: "127.0.0.1", port: 5555, mode: .ipV4)
        XCTAssertEqual(String(describing: ip), "127.0.0.1")
    }

    func testRemoteIPV6() throws {
        _ = try IP(remoteAddress: "::1", port: 5555, mode: .ipV6)
    }

    func testRemoteIPV4Prefered() throws {
        _ = try IP(remoteAddress: "127.0.0.1", port: 5555, mode: .ipV4Prefered)
    }

    func testRemoteIPV6Prefered() throws {
        _ = try IP(remoteAddress: "::1", port: 5555, mode: .ipV6Prefered)
    }

    func testInvalidPortIPV4() throws {
        XCTAssertThrowsError(try IP(port: 70000, mode: .ipV4))
    }

    func testInvalidPortIPV6() throws {
        XCTAssertThrowsError(try IP(port: 70000, mode: .ipV6))
    }

    func testInvalidPortIPV4Prefered() throws {
        XCTAssertThrowsError(try IP(port: 70000, mode: .ipV4Prefered))
    }

    func testInvalidPortIPV6Prefered() throws {
        XCTAssertThrowsError(try IP(port: 70000, mode: .ipV6Prefered))
    }

    func testInvalidLocalIPV4() throws {
        XCTAssertThrowsError(try IP(localAddress: "yo-yo ma", port: 5555, mode: .ipV4))
    }

    func testInvalidLocalIPV6() throws {
        XCTAssertThrowsError(try IP(localAddress: "yo-yo ma", port: 5555, mode: .ipV6))
    }

    func testInvalidLocalIPV4Prefered() throws {
        XCTAssertThrowsError(try IP(localAddress: "yo-yo ma", port: 5555, mode: .ipV4Prefered))
    }

    func testInvalidLocalIPV6Prefered() throws {
        XCTAssertThrowsError(try IP(localAddress: "yo-yo ma", port: 5555, mode: .ipV6Prefered))
    }

    func testRemoteInvalidPortIPV4() throws {
        XCTAssertThrowsError(try IP(remoteAddress: "127.0.0.1", port: 70000, mode: .ipV4))
    }

    func testRemoteInvalidPortIPV6() throws {
        XCTAssertThrowsError(try IP(remoteAddress: "::1", port: 70000, mode: .ipV6))
    }

    func testRemoteInvalidPortIPV4Prefered() throws {
        XCTAssertThrowsError(try IP(remoteAddress: "127.0.0.1", port: 70000, mode: .ipV4Prefered))
    }

    func testRemoteInvalidPortIPV6Prefered() throws {
        XCTAssertThrowsError(try IP(remoteAddress: "::1", port: 70000, mode: .ipV6Prefered))
    }
}

extension IPTests {
    public static var allTests: [(String, (IPTests) -> () throws -> Void)] {
        return [
            ("testErrorDescription", testErrorDescription),
            ("testLocalIPV4", testLocalIPV4),
            ("testLocalIPV6", testLocalIPV6),
            ("testLocalIPV4Prefered", testLocalIPV4Prefered),
            ("testLocalIPV6Prefered", testLocalIPV6Prefered),
            ("testLocalIPV4", testLocalIPV4),
            ("testLocalIPV6", testLocalIPV6),
            ("testLocalIPV4Prefered", testLocalIPV4Prefered),
            ("testLocalIPV6Prefered", testLocalIPV6Prefered),
            ("testRemoteIPV4", testRemoteIPV4),
            ("testRemoteIPV6", testRemoteIPV6),
            ("testRemoteIPV4Prefered", testRemoteIPV4Prefered),
            ("testRemoteIPV6Prefered", testRemoteIPV6Prefered),
            ("testInvalidPortIPV4", testInvalidPortIPV4),
            ("testInvalidPortIPV6", testInvalidPortIPV6),
            ("testInvalidPortIPV4Prefered", testInvalidPortIPV4Prefered),
            ("testInvalidPortIPV6Prefered", testInvalidPortIPV6Prefered),
            ("testInvalidLocalIPV4", testInvalidLocalIPV4),
            ("testInvalidLocalIPV6", testInvalidLocalIPV6),
            ("testInvalidLocalIPV4Prefered", testInvalidLocalIPV4Prefered),
            ("testInvalidLocalIPV6Prefered", testInvalidLocalIPV6Prefered),
            ("testRemoteInvalidPortIPV4", testRemoteInvalidPortIPV4),
            ("testRemoteInvalidPortIPV6", testRemoteInvalidPortIPV6),
            ("testRemoteInvalidPortIPV4Prefered", testRemoteInvalidPortIPV4Prefered),
            ("testRemoteInvalidPortIPV6Prefered", testRemoteInvalidPortIPV6Prefered),
        ]
    }
}
