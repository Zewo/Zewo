import XCTest
@testable import HTTPServer

enum TestRouterError : Error {
    case error
}

struct EmptyRouter : Router {}

struct TestRouter : Router {
    func custom(routes: Routes) {
        routes.get("/") { _ in
            return Response()
        }
    }
}

struct CustomRecoverRouter : Router {
    func custom(routes: Routes) {
        routes.get("/") { _ in
            throw TestRouterError.error
        }
    }

    func recover(error: Error) throws -> Response {
        return Response()
    }
}

public class RouterTests : XCTestCase {
    func testEmptyRouter() throws {
        let router = EmptyRouter()
        let request = Request()
        let response = try router.router.respond(to: request)
        XCTAssertEqual(response.status, .notFound)
    }

    func testRouter() throws {
        let router = TestRouter()
        let request = Request()
        let response = try router.router.respond(to: request)
        XCTAssertEqual(response.status, .ok)
    }

    func testCustomRecoverRouter() throws {
        let router = CustomRecoverRouter()
        let request = Request()
        let response = try router.router.respond(to: request)
        XCTAssertEqual(response.status, .ok)
    }
}

extension RouterTests {
    public static var allTests: [(String, (RouterTests) -> () throws -> Void)] {
        return [
            ("testEmptyRouter", testEmptyRouter),
            ("testRouter", testRouter),
            ("testCustomRecoverRouter", testCustomRecoverRouter),
        ]
    }
}
