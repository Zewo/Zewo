import XCTest
@testable import HTTP

public class RedirectMiddlewareTests : XCTestCase {
    let redirect = RedirectMiddleware(redirectTo: "/over-there", if: { $0.method == .get })

    func testDoesRedirect() throws {
        let request = Request()

        let responder = BasicResponder { _ in
            XCTFail("Should have redirected")
            return Response()
        }

        let response = try redirect.respond(to: request, chainingTo: responder)

        XCTAssertEqual(response.status, .found)
        XCTAssertEqual(response.headers["location"], "/over-there")
    }

    func testDoesntRedirect() throws {
        let request = Request(method: .post)

        let responder = BasicResponder { _ in
            return Response()
        }

        let response = try redirect.respond(to: request, chainingTo: responder)

        XCTAssertEqual(response.status, .ok)
        XCTAssertNotEqual(response.headers["location"], "/over-there")
    }
}

extension RedirectMiddlewareTests {
    public static var allTests: [(String, (RedirectMiddlewareTests) -> () throws -> Void)] {
        return [
            ("testDoesRedirect", testDoesRedirect),
            ("testDoesntRedirect", testDoesntRedirect),
        ]
    }
}
