import XCTest
@testable import Media

struct B : Codable {
    let f: UInt8
}

extension B : Equatable {
    static func ==(lhs: B, rhs: B) -> Bool {
        return lhs.f == rhs.f
    }
}

struct A : Codable {
    let a: Int
    let b: String?
    let c: [Double]
    let d: [String: Float]
    let e: B
}

extension A : Equatable {
    static func ==(lhs: A, rhs: A) -> Bool {
        return lhs.a == rhs.a &&
        lhs.b == rhs.b &&
        lhs.c == rhs.c &&
        lhs.d == rhs.d &&
        lhs.e == rhs.e
    }
}

public class JSONTests : XCTestCase {
    func testEncoding() throws {
        let a = A(
            a: 42,
            b: nil,
            c: [4.2],
            d: ["foo": 6.9],
            e: B(f: 23)
        )
        
        let json = try JSON.encode(a)
        let b: A = try JSON.decode(json)
        
        XCTAssertEqual(a, b)
    }
    
    func testJSONSchema() throws {
        let schema = JSON.Schema([
            "type": "object",
            "properties": [
                "name": ["type": "string"],
                "price": ["type": "number"],
            ],
            "required": ["name"],
        ])
        
        var result = schema.validate(["name": "Eggs", "price": 34.99])
        XCTAssert(result.isValid)
        
        result = schema.validate(["price": 34.99])
        XCTAssertEqual(result.errors, ["Required properties are missing '[\"name\"]\'"])
    }
}

extension JSONTests {
    public static var allTests: [(String, (JSONTests) -> () throws -> Void)] {
        return [
            ("testJSONSchema", testJSONSchema),
        ]
    }
}
