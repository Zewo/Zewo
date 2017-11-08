import XCTest
@testable import Media

public class JSONTests : XCTestCase {
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
    
    func testSerialize() throws {
        let json: JSON = ["string": "string", "int": 1, "bool": true, "nil": nil, "array":["a": 1, "b": 2], "object": ["c": "d", "e": "f"], "intarray": [1, 2, 3, 5]]
        
        var s: String?
        try JSONSerializer().serialize(json) { (buf) in
            s = String(buf)
        }
        
        XCTAssertEqual("{\"nil\":null,\"intarray\":[1,2,3,5],\"object\":{\"e\":\"f\",\"c\":\"d\"},\"array\":{\"b\":2,\"a\":1},\"int\":1,\"bool\":true,\"string\":\"string\"}", s)
    }
    
    func testJSONFromVariables() throws {
        let var0 = "hello"
        let var1: JSON = JSON(stringLiteral:var0)

        let array: JSON = ["string": var1, "int": 1, "bool": true, "nil": nil, "array":["a": 1, "b": 2], "object": ["c": "d", "e": "f"], "intarray": [1, 2, 3, 5]]
        
        var s: String?
        try JSONSerializer().serialize(array) { (buf) in
            s = String(buf)
        }
        
        XCTAssertEqual("{\"nil\":null,\"intarray\":[1,2,3,5],\"object\":{\"e\":\"f\",\"c\":\"d\"},\"array\":{\"b\":2,\"a\":1},\"int\":1,\"bool\":true,\"string\":\"hello\"}", s)
    }
    
    func testParseFromString() throws {
        let str = "{\"nil\":null,\"intarray\":[1,2,3,5],\"object\":{\"e\":\"f\",\"c\":\"d\"},\"array\":{\"b\":2,\"a\":1},\"int\":1,\"bool\":true,\"string\":\"string\"}"
        
        let json = try str.withBuffer { (b) -> JSON in
            return try JSON(from: b, deadline: .never)
        }
        let json2: JSON = ["string": "string", "int": 1, "bool": true, "nil": nil, "array":["a": 1, "b": 2], "object": ["c": "d", "e": "f"], "intarray": [1, 2, 3, 5]]

        XCTAssertEqual(json, json2)
    }
    
    func testSubscript() throws {
        let str = "{\"nil\":null,\"intarray\":[1,2,3,5],\"object\":{\"e\":\"f\",\"c\":\"d\"},\"array\":{\"b\":2,\"a\":1},\"int\":1,\"bool\":true,\"string\":\"string\"}"
        
        let json = try str.withBuffer { (b) -> JSON in
            return try JSON(from: b, deadline: .never)
        }
        
        XCTAssertEqual(json["not"], .null)
        XCTAssertEqual(json["intarray"][1], 2)
        XCTAssertEqual(json["object"]["e"], "f")
    }
}

extension JSONTests {
    public static var allTests: [(String, (JSONTests) -> () throws -> Void)] {
        return [
            ("testJSONSchema", testJSONSchema),
            ("testSerialize", testSerialize),
            ("testParseFromString", testParseFromString),
            ("testSubscript", testSubscript),
        ]
    }
}
