import XCTest
@testable import HTTP

public class BasicAuthMiddlewareTests : XCTestCase {
    func testBasicAuthMiddleware() throws {
        var serverBasicAuth = BasicAuthMiddleware(realm: "Zewo") { username, password in
            if username == "foo" && password == "bar" {
                return .authenticated
            }

            if username == "fuu" && password == "baz" {
                return .payload(key: "user", value: "bonzo")
            }

            return .accessDenied
        }

        var called = false
        var responder = BasicResponder { _ in
            called = true
            return Response()
        }

        let request = Request()
        var clientBasicAuth = BasicAuthMiddleware(username: "foo", password: "bar")
        var response = try [clientBasicAuth, serverBasicAuth].chain(to: responder).respond(to: request)

        XCTAssert(called)
        XCTAssertEqual(response.status, .ok)

        called = false
        responder = BasicResponder { request in
            called = true
            guard let value = request.storage["user"] as? String else {
                XCTFail("Should've set payload")
                return Response(status: .internalServerError)
            }
            XCTAssertEqual(value, "bonzo")
            return Response()
        }

        clientBasicAuth = BasicAuthMiddleware(username: "fuu", password: "baz")
        response = try [clientBasicAuth, serverBasicAuth].chain(to: responder).respond(to: request)

        XCTAssert(called)
        XCTAssertEqual(response.status, .ok)

        responder = BasicResponder { _ in
            XCTFail("Should've been bypassed")
            return Response()
        }

        clientBasicAuth = BasicAuthMiddleware(username: "fou", password: "boy")
        response = try [clientBasicAuth, serverBasicAuth].chain(to: responder).respond(to: request)

        XCTAssertEqual(response.status, .unauthorized)
        XCTAssertEqual(response.headers["WWW-Authenticate"], "Basic realm=\"Zewo\"")

        serverBasicAuth = BasicAuthMiddleware { username, password in
            return .accessDenied
        }

        clientBasicAuth = BasicAuthMiddleware(username: "fou", password: "boy")
        response = try [clientBasicAuth, serverBasicAuth].chain(to: responder).respond(to: request)

        XCTAssertEqual(response.status, .unauthorized)
    }

    func testInvalidRequests() throws {
        let basicAuth = BasicAuthMiddleware(realm: "Zewo") { username, password in
            return .accessDenied
        }

        let responder = BasicResponder { _ in
            XCTFail("Should've been bypassed")
            return Response()
        }

        var request = Request()
        var response = try basicAuth.respond(to: request, chainingTo: responder)
        XCTAssertEqual(response.status, .unauthorized)

        request.authorization = ""
        response = try basicAuth.respond(to: request, chainingTo: responder)
        XCTAssertEqual(response.status, .unauthorized)

        request.authorization = "Basic foo"
        response = try basicAuth.respond(to: request, chainingTo: responder)
        XCTAssertEqual(response.status, .unauthorized)

        request.authorization = "Basic Zm9v"
        response = try basicAuth.respond(to: request, chainingTo: responder)
        XCTAssertEqual(response.status, .unauthorized)
    }
}

extension BasicAuthMiddlewareTests {
    public static var allTests: [(String, (BasicAuthMiddlewareTests) -> () throws -> Void)] {
        return [
            ("testBasicAuthMiddleware", testBasicAuthMiddleware),
            ("testInvalidRequests", testInvalidRequests),
        ]
    }
}
