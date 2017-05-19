import XCTest
import Venice
import Core
import struct Foundation.URL
@testable import HTTP

public class ClientTests: XCTestCase {
    let deadline: Deadline = .never
    
    func testClient() throws {
        let client = try Client(url: "https://api.github.com")
        let response = try client.get("/zen")
        let body: String = try response.getContent(.plainText)
        print(body)
    }
}

extension ClientTests {
    public static var allTests: [(String, (ClientTests) -> () throws -> Void)] {
        return [
            ("testClient", testClient),
        ]
    }
}
