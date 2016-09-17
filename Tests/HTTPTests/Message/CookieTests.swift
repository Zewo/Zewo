import XCTest
@testable import HTTP

public class CookieTests : XCTestCase {
    func testConstruction() throws {
        let cookieString = "foo=bar"
        let cookie = Cookie(
            name: "foo",
            value: "bar"
        )
        XCTAssertEqual(cookie, cookie)
        XCTAssertEqual(String(describing: cookie), cookieString)
        XCTAssertEqual(cookie.name, "foo")
        XCTAssertEqual(cookie.value, "bar")
    }

    func testParsing() throws {
        var cookieString = "foo=bar; fuu=baz"
        var cookies = Set<Cookie>(cookieHeader: cookieString)
        XCTAssertNotNil(cookies)
        XCTAssertTrue(cookies?.contains(Cookie(name: "foo", value: "bar")) ?? false)
        XCTAssertTrue(cookies?.contains(Cookie(name: "fuu", value: "baz")) ?? false)

        cookieString = "foo; fuu"
        cookies = Set<Cookie>(cookieHeader: cookieString)
        XCTAssertNil(cookies)
    }
}

extension CookieTests {
    public static var allTests: [(String, (CookieTests) -> () throws -> Void)] {
        return [
            ("testConstruction", testConstruction),
            ("testParsing", testParsing),
        ]
    }
}
