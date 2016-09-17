import XCTest
@testable import HTTP

public class AttributedCookieTests : XCTestCase {
    func testConstruction() throws {
        let cookieString = "foo=bar; Expires=Thu, 01 Jan 1970 00:00:01 GMT; Domain=zewo.io; Path=/libs; Secure; HttpOnly"
        let cookie = AttributedCookie(
            name: "foo",
            value: "bar",
            expiration: .expires("Thu, 01 Jan 1970 00:00:01 GMT"),
            domain: "zewo.io",
            path: "/libs",
            secure: true,
            httpOnly: true
        )
        XCTAssertEqual(cookie, cookie)
        XCTAssertEqual(String(describing: cookie), cookieString)
        XCTAssertEqual(cookie.name, "foo")
        XCTAssertEqual(cookie.value, "bar")
        XCTAssertEqual(cookie.expiration, .expires("Thu, 01 Jan 1970 00:00:01 GMT"))
        XCTAssertEqual(cookie.domain, "zewo.io")
        XCTAssertEqual(cookie.path, "/libs")
        XCTAssertTrue(cookie.secure)
        XCTAssertTrue(cookie.httpOnly)
    }

    func testParsing() throws {
        var cookieString = "foo=bar; Expires=Thu, 01 Jan 1970 00:00:01 GMT; Domain=zewo.io; Path=/libs; Secure; HttpOnly"
        var parsedCookie = AttributedCookie(cookieString)
        XCTAssertNotNil(parsedCookie)
        XCTAssertEqual(parsedCookie?.name, "foo")
        XCTAssertEqual(parsedCookie?.value, "bar")
        XCTAssertEqual(parsedCookie?.expiration, .expires("Thu, 01 Jan 1970 00:00:01 GMT"))
        XCTAssertEqual(parsedCookie?.domain, "zewo.io")
        XCTAssertEqual(parsedCookie?.path, "/libs")
        XCTAssertTrue(parsedCookie?.secure ?? false)
        XCTAssertTrue(parsedCookie?.httpOnly ?? false)

        cookieString = "foo=bar; Max-Age=60; Domain=zewo.io; Path=/libs; Secure; HttpOnly"
        parsedCookie = AttributedCookie(cookieString)
        XCTAssertNotNil(parsedCookie)
        XCTAssertEqual(parsedCookie?.name, "foo")
        XCTAssertEqual(parsedCookie?.value, "bar")
        XCTAssertEqual(parsedCookie?.expiration, .maxAge(60))
        XCTAssertEqual(parsedCookie?.domain, "zewo.io")
        XCTAssertEqual(parsedCookie?.path, "/libs")
        XCTAssertTrue(parsedCookie?.secure ?? false)
        XCTAssertTrue(parsedCookie?.httpOnly ?? false)

        cookieString = "foo"
        parsedCookie = AttributedCookie(cookieString)
        XCTAssertNil(parsedCookie)

        cookieString = "foo=bar; Max-Age=60=60"
        parsedCookie = AttributedCookie(cookieString)
        XCTAssertNil(parsedCookie)
    }

    func testExpirationEquality() {
        var expirationA = AttributedCookie.Expiration.expires("Thu, 01 Jan 1970 00:00:01 GMT")
        var expirationB = AttributedCookie.Expiration.expires("Thu, 01 Jan 1970 00:00:01 GMT")
        XCTAssertEqual(expirationA, expirationB)

        expirationA = AttributedCookie.Expiration.maxAge(60)
        expirationB = AttributedCookie.Expiration.maxAge(60)
        XCTAssertEqual(expirationA, expirationB)

        expirationA = AttributedCookie.Expiration.expires("Thu, 01 Jan 1970 00:00:01 GMT")
        expirationB = AttributedCookie.Expiration.maxAge(60)
        XCTAssertNotEqual(expirationA, expirationB)
    }
}

extension AttributedCookieTests {
    public static var allTests: [(String, (AttributedCookieTests) -> () throws -> Void)] {
        return [
            ("testConstruction", testConstruction),
            ("testParsing", testParsing),
            ("testExpirationEquality", testExpirationEquality),
        ]
    }
}
