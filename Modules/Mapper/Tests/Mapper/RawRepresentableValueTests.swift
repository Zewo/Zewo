import XCTest
@testable import Mapper

class RawRepresentableValueTests: XCTestCase {
    static var allTests: [(String, (RawRepresentableValueTests) -> () throws -> Void)] {
        return [
            ("testRawRepresentable", testRawRepresentable),
            ("testRawRepresentableNumber", testRawRepresentableNumber),
            ("testRawRepresentableInt", testRawRepresentableInt),
            ("testMissingRawRepresentableNumber", testMissingRawRepresentableNumber),
            ("testOptionalRawRepresentable", testOptionalRawRepresentable),
            ("testExistingOptionalRawRepresentable", testExistingOptionalRawRepresentable),
            ("testRawRepresentableTypeMismatch", testRawRepresentableTypeMismatch),
            ("testRawRepresentableArray", testRawRepresentableArray),
            ("testRawRepresentablePartialArray", testRawRepresentablePartialArray),
            ("testRawRepresentableOptionalArray", testRawRepresentableOptionalArray),
            ("testRawRepresentableExistingOptionalArray", testRawRepresentableExistingOptionalArray)
        ]
    }

    func testRawRepresentable() {
        enum Suits: String {
            case Hearts = "hearts"
            case Barney = "barney"
        }
        struct Test: Mappable {
            let suit: Suits
            init(mapper: Mapper) throws {
                try self.suit = mapper.map(from: "suit")
            }
        }
        let test = try! Test(mapper: Mapper(structuredData: ["suit": "barney"]))
        XCTAssertEqual(test.suit, Suits.Barney)
    }

    func testRawRepresentableNumber() {
        enum Value: Double {
            case first = 1.0
        }
        struct Test: Mappable {
            let value: Value
            init(mapper: Mapper) throws {
                try self.value = mapper.map(from: "value")
            }
        }
        let test = try! Test(mapper: Mapper(structuredData: ["value": 1.0]))
        XCTAssertEqual(test.value, Value.first)
    }

    func testRawRepresentableInt() {
        enum Value: Int {
            case first = 1
        }
        struct Test: Mappable {
            let value: Value
            init(mapper: Mapper) throws {
                try self.value = mapper.map(from: "value")
            }
        }
        let test = try! Test(mapper: Mapper(structuredData: ["value": 1]))
        XCTAssertEqual(test.value, Value.first)
    }

    func testMissingRawRepresentableNumber() {
        enum Value: Double {
            case First = 1.0
        }
        struct Test: Mappable {
            let value: Value
            init(mapper: Mapper) throws {
                try self.value = mapper.map(from: "value")
            }
        }
        let test = try? Test(mapper: Mapper(structuredData: .null))
        XCTAssertNil(test)
    }

    func testOptionalRawRepresentable() {
        enum Value: Double {
            case First = 1.0
        }
        struct Test: Mappable {
            let value: Value?
            init(mapper: Mapper) throws {
                self.value = mapper.map(optionalFrom: "value")
            }
        }
        let test = try! Test(mapper: Mapper(structuredData: .null))
        XCTAssertNil(test.value)
    }

    func testExistingOptionalRawRepresentable() {
        enum Value: Double {
            case First = 1.0
        }
        struct Test: Mappable {
            let value: Value?
            init(mapper: Mapper) throws {
                self.value = mapper.map(optionalFrom: "value")
            }
        }
        let test = try! Test(mapper: Mapper(structuredData: ["value": 1.0]))
        XCTAssertEqual(test.value, Value.First)
    }

    func testRawRepresentableTypeMismatch() {
        enum Value: Double {
            case First = 1.0
        }
        struct Test: Mappable {
            let value: Value?
            init(mapper: Mapper) throws {
                self.value = mapper.map(optionalFrom: "value")
            }
        }
        let test = try! Test(mapper: Mapper(structuredData: ["value": "cike"]))
        XCTAssertNil(test.value)
    }

    func testRawRepresentableArray() {
        enum Barney: String {
            case stinson, awesome, legendary
        }
        struct Test: Mappable {
            let barneys: [Barney]
            init(mapper: Mapper) throws {
                try self.barneys = mapper.map(arrayFrom: "barneys")
            }
        }
        let barneysContent: StructuredData = ["barneys": ["legendary", "stinson", "awesome"]]
        let test = try! Test(mapper: Mapper(structuredData: barneysContent))
        XCTAssertEqual(test.barneys, [Barney.legendary, Barney.stinson, Barney.awesome])
    }

    func testRawRepresentablePartialArray() {
        enum Barney: String {
            case stinson, awesome, legendary
        }
        struct Test: Mappable {
            let barneys: [Barney]
            init(mapper: Mapper) throws {
                try self.barneys = mapper.map(arrayFrom: "barneys")
            }
        }
        let barneysContent: StructuredData = ["barneys": ["legendary", "stinson", "captain"]]
        let test = try! Test(mapper: Mapper(structuredData: barneysContent))
        XCTAssertEqual(test.barneys, [Barney.legendary, Barney.stinson])
    }

    func testRawRepresentableOptionalArray() {
        enum Barney: String {
            case stinson, awesome, legendary
        }
        struct Test: Mappable {
            let barneys: [Barney]?
            init(mapper: Mapper) throws {
                self.barneys = mapper.map(optionalArrayFrom: "barneys")
            }
        }
        let test = try! Test(mapper: Mapper(structuredData: .null))
        XCTAssertNil(test.barneys)
    }

    func testRawRepresentableExistingOptionalArray() {
        enum Barney: String {
            case stinson, awesome, legendary
        }
        struct Test: Mappable {
            let barneys: [Barney]?
            init(mapper: Mapper) throws {
                self.barneys = mapper.map(optionalArrayFrom: "barneys")
            }
        }
        let barneysContent: StructuredData = ["barneys": ["legendary", "stinson", "awesome"]]
        let test = try! Test(mapper: Mapper(structuredData: barneysContent))
        XCTAssertEqual(test.barneys!, [Barney.legendary, Barney.stinson, Barney.awesome])
    }
}
