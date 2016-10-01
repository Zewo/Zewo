import XCTest
@testable import HTTP

public class BufferServerContentNegotiationMiddlewareTests : XCTestCase {
    let contentNegotiation = ServerContentNegotiationMiddleware(mediaTypes: [JSON.self, URLEncodedForm.self], mode: .buffer)

    func testJSONRequestDefaultResponse() throws {
        let request = Request(
            headers: [
                "Content-Type": "application/json; charset=utf-8"
            ],
            body: "{\"foo\":\"bar\"}"
        )

        let responder = BasicResponder { request in
            XCTAssertEqual(request.content, ["foo": "bar"])
            return Response(content: ["fuu": "baz"])
        }

        let response = try contentNegotiation.respond(to: request, chainingTo: responder)

        // Because there was no Accept header we serializer with the first media type in the
        // content negotiation middleware media type list. In this case JSON.
        XCTAssertEqual(response.headers["Content-Type"], "application/json; charset=utf-8")
        XCTAssertEqual(response.body, .buffer(Buffer("{\"fuu\":\"baz\"}")))
    }

    func testJSONRequestResponse() throws {
        let request = Request(
            headers: [
                "Content-Type": "application/json; charset=utf-8",
                "Accept": "application/json"
            ],
            body: "{\"foo\":\"bar\"}"
        )

        let responder = BasicResponder { request in
            XCTAssertEqual(request.content, ["foo": "bar"])
            return Response(content: ["fuu": "baz"])
        }

        let response = try contentNegotiation.respond(to: request, chainingTo: responder)

        XCTAssertEqual(response.headers["Content-Type"], "application/json; charset=utf-8")
        XCTAssertEqual(response.body, .buffer(Buffer("{\"fuu\":\"baz\"}")))
    }

    func testJSONRequestURLEncodedFormResponse() throws {
        let request = Request(
            headers: [
                "Content-Type": "application/json; charset=utf-8",
                "Accept": "application/x-www-form-urlencoded"
            ],
            body: "{\"foo\":\"bar\"}"
        )

        let responder = BasicResponder { request in
            XCTAssertEqual(request.content, ["foo": "bar"])
            return Response(content: ["fuu": "baz"])
        }

        let response = try contentNegotiation.respond(to: request, chainingTo: responder)

        XCTAssertEqual(response.headers["Content-Type"], "application/x-www-form-urlencoded; charset=utf-8")
        XCTAssertEqual(response.body, .buffer(Buffer("fuu=baz")))
    }

    func testURLEncodedFormRequestDefaultResponse() throws {
        let request = Request(
            headers: [
                "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
            ],
            body: "foo=bar"
        )

        let responder = BasicResponder { request in
            XCTAssertEqual(request.content, ["foo": "bar"])
            return Response(content: ["fuu": "baz"])
        }

        let response = try contentNegotiation.respond(to: request, chainingTo: responder)

        // Because there was no Accept header we serializer with the first media type in the
        // content negotiation middleware media type list. In this case JSON.
        XCTAssertEqual(response.headers["Content-Type"], "application/json; charset=utf-8")
        XCTAssertEqual(response.body, .buffer(Buffer("{\"fuu\":\"baz\"}")))
    }

    func testURLEncodedFormRequestResponse() throws {
        let request = Request(
            headers: [
                "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
                "Accept": "application/x-www-form-urlencoded"
            ],
            body: "foo=bar"
        )

        let responder = BasicResponder { request in
            XCTAssertEqual(request.content, ["foo": "bar"])
            return Response(content: ["fuu": "baz"])
        }

        let response = try contentNegotiation.respond(to: request, chainingTo: responder)

        XCTAssertEqual(response.headers["Content-Type"], "application/x-www-form-urlencoded; charset=utf-8")
        XCTAssertEqual(response.body, .buffer(Buffer("fuu=baz")))
    }

    func testURLEncodedFormRequestJSONResponse() throws {
        let request = Request(
            headers: [
                "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
                "Accept": "application/json"
            ],
            body: "foo=bar"
        )

        let responder = BasicResponder { request in
            XCTAssertEqual(request.content, ["foo": "bar"])
            return Response(content: ["fuu": "baz"])
        }

        let response = try contentNegotiation.respond(to: request, chainingTo: responder)

        XCTAssertEqual(response.headers["Content-Type"], "application/json; charset=utf-8")
        XCTAssertEqual(response.body, .buffer(Buffer("{\"fuu\":\"baz\"}")))
    }
}

extension BufferServerContentNegotiationMiddlewareTests {
    public static var allTests: [(String, (BufferServerContentNegotiationMiddlewareTests) -> () throws -> Void)] {
        return [
            ("testJSONRequestDefaultResponse", testJSONRequestDefaultResponse),
            ("testJSONRequestResponse", testJSONRequestResponse),
            ("testJSONRequestURLEncodedFormResponse", testJSONRequestURLEncodedFormResponse),
            ("testURLEncodedFormRequestDefaultResponse", testURLEncodedFormRequestDefaultResponse),
            ("testURLEncodedFormRequestResponse", testURLEncodedFormRequestResponse),
            ("testURLEncodedFormRequestJSONResponse", testURLEncodedFormRequestJSONResponse),
        ]
    }
}
