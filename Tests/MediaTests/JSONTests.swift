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
        let json: JSON = [
            "string": "string",
            "int": 1,
            "bool": true,
            "nil": nil,
            "array":["a": 1, "b": 2],
            "object": ["c": "d", "e": "f"],
            "intarray": [1, 2, 3, 5]
        ]
        
        var string: String?
        
        try JSONSerializer(ordering: true).serialize(json) { buffer in
            string = String(buffer)
        }
    XCTAssertEqual("{\"array\":{\"a\":1,\"b\":2},\"bool\":true,\"int\":1,\"intarray\":[1,2,3,5],\"nil\":null,\"object\":{\"c\":\"d\",\"e\":\"f\"},\"string\":\"string\"}", string)
    }
    
    func testJSONFromVariables() throws {
        let jsonString: JSON = "hello"

        let jsonObject: JSON = [
            "string": jsonString,
            "int": 1,
            "bool": true,
            "nil": nil,
            "array":["a": 1, "b": 2],
            "object": ["c": "d", "e": "f"],
            "intarray": [1, 2, 3, 5]
        ]
        
        var string: String?
        
        try JSONSerializer(ordering: true).serialize(jsonObject) { buffer in
            string = String(buffer)
        }
    XCTAssertEqual("{\"array\":{\"a\":1,\"b\":2},\"bool\":true,\"int\":1,\"intarray\":[1,2,3,5],\"nil\":null,\"object\":{\"c\":\"d\",\"e\":\"f\"},\"string\":\"hello\"}", string)
    }
    
    func testParseFromString() throws {
        let string = "{\"nil\":null,\"intarray\":[1,2,3,5],\"object\":{\"e\":\"f\",\"c\":\"d\"},\"array\":{\"b\":2,\"a\":1},\"int\":1,\"bool\":true,\"string\":\"string\"}"
        
        let jsonA = try string.withBuffer { buffer -> JSON in
            return try JSON(from: buffer, deadline: .never)
        }
        
        let jsonB: JSON = [
            "string": "string",
            "int": 1,
            "bool": true,
            "nil": nil,
            "array":["a": 1, "b": 2],
            "object": ["c": "d", "e": "f"],
            "intarray": [1, 2, 3, 5]
        ]

        XCTAssertEqual(jsonA, jsonB)
    }
    
    func testSubscript() throws {
        let string = "{\"nil\":null,\"intarray\":[1,2,3,5],\"object\":{\"e\":\"f\",\"c\":\"d\"},\"array\":{\"b\":2,\"a\":1},\"int\":1,\"bool\":true,\"string\":\"string\"}"
        
        let json = try string.withBuffer { buffer -> JSON in
            return try JSON(from: buffer, deadline: .never)
        }
        
        XCTAssertEqual(json["not"], nil)
        XCTAssertEqual(json["intarray"]![1], 2)
        XCTAssertEqual(json["object"]!["e"], "f")
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
