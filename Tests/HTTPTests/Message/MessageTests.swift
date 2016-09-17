import XCTest
@testable import HTTP

public class MessageTests : XCTestCase {
    func testHeadersCaseInsensitivity() {
        let headers: Headers = [
            "Content-Type": "application/json",
        ]
        XCTAssertEqual(headers["content-TYPE"], "application/json")
    }

    func testHeadersDescription() {
        let headers: Headers = [
            "Content-Type": "application/json",
        ]
        XCTAssertEqual(String(describing: headers), "Content-Type: application/json\n")
    }

    func testHeadersEquality() {
        let headers: Headers = [
            "Content-Type": "application/json",
        ]
        XCTAssertEqual(headers, headers)
    }

    func testContentTypeHeader() {
        let mediaType = MediaType(type: "application", subtype: "json")
        var request = Request(headers: ["Content-Type": "application/json"])
        XCTAssertEqual(request.contentType, mediaType)
        request.contentType = mediaType
        XCTAssertEqual(request.headers["Content-Type"], "application/json")
    }

    func testContentLengthHeader() {
        var request = Request()
        XCTAssertEqual(request.contentLength, 0)
        request.contentLength = 420
        XCTAssertEqual(request.headers["Content-Length"], "420")
    }

    func testTransferEncodingHeader() {
        var request = Request(headers: ["Transfer-Encoding": "foo"])
        XCTAssertEqual(request.transferEncoding, "foo")
        request.transferEncoding = "chunked"
        XCTAssertTrue(request.isChunkEncoded)
    }

    func testConnectionHeader() {
        var request = Request(headers: ["Connection": "foo"])
        XCTAssertEqual(request.connection, "foo")
        request.connection = "bar"
        XCTAssertEqual(request.headers["Connection"], "bar")
        XCTAssertEqual(request.connection, "bar")
    }

    func testIsKeepAlive() {
        var request = Request()
        XCTAssertTrue(request.isKeepAlive)
        request.connection = "close"
        XCTAssertFalse(request.isKeepAlive)
        request.version.minor = 0
        request.connection = nil
        XCTAssertFalse(request.isKeepAlive)
        request.connection = "keep-alive"
        XCTAssertTrue(request.isKeepAlive)
    }

    func testIsUpgrade() {
        var request = Request(headers: ["Connection": "foo"])
        XCTAssertFalse(request.isUpgrade)
        request.connection = "upgrade"
        XCTAssertTrue(request.isUpgrade)
    }

    func testUpgradeHeader() {
        var request = Request(headers: ["Upgrade": "foo"])
        XCTAssertEqual(request.upgrade, "foo")
        request.upgrade = "bar"
        XCTAssertEqual(request.headers["Upgrade"], "bar")
        XCTAssertEqual(request.upgrade, "bar")
    }

    func testStorageDescription() {
        var request = Request()
        XCTAssertEqual(request.storageDescription, "Storage:\n-")
        request.storage["foo"] = "bar"
        XCTAssertEqual(request.storageDescription, "Storage:\nfoo: bar\n")
    }
}

extension MessageTests {
    public static var allTests: [(String, (MessageTests) -> () throws -> Void)] {
        return [
            ("testHeadersCaseInsensitivity", testHeadersCaseInsensitivity),
            ("testContentTypeHeader", testHeadersDescription),
            ("testContentTypeHeader", testHeadersEquality),
            ("testContentTypeHeader", testContentTypeHeader),
            ("testContentTypeHeader", testContentLengthHeader),
            ("testContentTypeHeader", testTransferEncodingHeader),
            ("testContentTypeHeader", testConnectionHeader),
            ("testContentTypeHeader", testIsKeepAlive),
            ("testContentTypeHeader", testIsUpgrade),
            ("testContentTypeHeader", testUpgradeHeader),
            ("testContentTypeHeader", testStorageDescription),
        ]
    }
}
