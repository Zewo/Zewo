import XCTest
@testable import HTTPServer

enum TestResourceError : Error {
    case error
}

struct EmptyResource : Resource {}

struct TestResource : Resource {
    func custom(routes: ResourceRoutes) {
        routes.get("/foo") { _ in
            return Response()
        }
    }
}

struct CustomRecoverResource : Resource {
    func custom(routes: ResourceRoutes) {
        routes.get("/foo") { _ in
            throw TestRouterError.error
        }
    }

    func recover(error: Error) throws -> Response {
        return Response()
    }
}

struct CompleteResource : Resource {
    func list(request: Request) throws -> Response {
        return Response()
    }

    func create(request: Request, content: Map) throws -> Response {
        XCTAssertEqual(content, 420)
        return Response()
    }

    func detail(request: Request, id: String) throws -> Response {
        XCTAssertEqual(id, "foo")
        return Response()
    }

    func update(request: Request, id: String, content: Map) throws -> Response {
        XCTAssertEqual(id, "foo")
        XCTAssertEqual(content, 420)
        return Response()
    }

    func destroy(request: Request, id: Int) throws -> Response {
        XCTAssertEqual(id, 1969)
        return Response()
    }
}

public class ResourceTests : XCTestCase {
    func testEmptyResource() throws {
        let resource = EmptyResource()
        var request = Request()
        var response = try resource.router.respond(to: request)
        XCTAssertEqual(response.status, .notFound)

        request = Request(method: .post)
        request.content = 420
        response = try resource.router.respond(to: request)
        XCTAssertEqual(response.status, .notFound)

        request = Request(method: .get, url: "/foo")!
        response = try resource.router.respond(to: request)
        XCTAssertEqual(response.status, .notFound)

        request = Request(method: .patch, url: "/foo")!
        request.content = 420
        response = try resource.router.respond(to: request)
        XCTAssertEqual(response.status, .notFound)

        request = Request(method: .delete, url: "/foo")!
        response = try resource.router.respond(to: request)
        XCTAssertEqual(response.status, .notFound)
    }

    func testResource() throws {
        let resource = TestResource()
        let request = Request(method: .get, url: "/foo")!
        let response = try resource.router.respond(to: request)
        XCTAssertEqual(response.status, .ok)
    }

    func testCustomRecoverResource() throws {
        let resource = CustomRecoverResource()
        let request = Request(method: .get, url: "/foo")!
        let response = try resource.router.respond(to: request)
        XCTAssertEqual(response.status, .ok)
    }

    func testCompleteResource() throws {
        let resource = CompleteResource()

        var request = Request()
        var response = try resource.router.respond(to: request)
        XCTAssertEqual(response.status, .ok)

        request = Request(method: .post)
        request.content = 420
        response = try resource.router.respond(to: request)
        XCTAssertEqual(response.status, .ok)

        request = Request(method: .get, url: "/foo")!
        response = try resource.router.respond(to: request)
        XCTAssertEqual(response.status, .ok)

        request = Request(method: .patch, url: "/foo")!
        request.content = 420
        response = try resource.router.respond(to: request)
        XCTAssertEqual(response.status, .ok)

        request = Request(method: .delete, url: "/1969")!
        response = try resource.router.respond(to: request)
        XCTAssertEqual(response.status, .ok)
    }
}

extension ResourceTests {
    public static var allTests: [(String, (ResourceTests) -> () throws -> Void)] {
        return [
            ("testEmptyResource", testEmptyResource),
            ("testResource", testResource),
            ("testCustomRecoverResource", testCustomRecoverResource),
            ("testCompleteResource", testCompleteResource),
        ]
    }
}
