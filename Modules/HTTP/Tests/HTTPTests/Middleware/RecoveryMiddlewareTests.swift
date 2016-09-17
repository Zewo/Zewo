import XCTest
@testable import HTTP

enum RecoveryMiddlewareTestError : Error {
    case error
}

public class RecoveryMiddlewareTests : XCTestCase {
    func testRecoveryMiddleware() throws {
        let request = Request()

        var responder = BasicResponder { _ in
            throw HTTPError.badRequest
        }

        var recovery = RecoveryMiddleware()
        var response = try recovery.respond(to: request, chainingTo: responder)
        XCTAssertEqual(response.status, .badRequest)

        responder = BasicResponder { _ in
            throw RecoveryMiddlewareTestError.error
        }

        recovery = RecoveryMiddleware()
        XCTAssertThrowsError(try recovery.respond(to: request, chainingTo: responder))

        responder = BasicResponder { _ in
            throw RecoveryMiddlewareTestError.error
        }

        recovery = RecoveryMiddleware { error in
            switch error {
            case RecoveryMiddlewareTestError.error:
                return Response(status: .internalServerError)
            default:
                XCTFail("Should've recovered")
                throw error
            }
        }

        response = try recovery.respond(to: request, chainingTo: responder)
        XCTAssertEqual(response.status, .internalServerError)

        responder = BasicResponder { _ in
            return Response()
        }

        recovery = RecoveryMiddleware { error in
            XCTFail("Should've not been called")
            throw error
        }

        response = try recovery.respond(to: request, chainingTo: responder)
        XCTAssertEqual(response.status, .ok)
    }
}

extension RecoveryMiddlewareTests {
    public static var allTests: [(String, (RecoveryMiddlewareTests) -> () throws -> Void)] {
        return [
            ("testRecoveryMiddleware", testRecoveryMiddleware),
        ]
    }
}
