import XCTest
import Foundation
@testable import Media

struct User : Codable {
    let firstName: String
}

class MapperTests : XCTestCase {
    func test() throws {
        let json: JSON = ["firstName": "Paulo"]
        
        let user = try User(from: json)
        
        XCTAssertEqual(user.firstName, "Paulo")
    }
}
