import XCTest
@testable import Mapper

final class OptionalValueTests: XCTestCase {
    static var allTests: [(String, (OptionalValueTests) -> () throws -> Void)] {
        return [
            ("testMappingToClass", testMappingToClass),
            ("testMappingOptionalValue", testMappingOptionalValue),
            ("testMappingOptionalExisitngValue", testMappingOptionalExisitngValue),
            ("testMappingOptionalArray", testMappingOptionalArray),
            ("testMappingOptionalExistingArray", testMappingOptionalExistingArray),
        ]
    }

    func testMappingToClass() {
        final class Test: Mappable {
            let string: String
            required init(mapper: Mapper) throws {
                self.string = mapper.map(optionalFrom: "string") ?? ""
            }
        }
        let test = try! Test(mapper: Mapper(structuredData: ["string": "Hello"]))
        XCTAssertEqual(test.string, "Hello")
    }

    func testMappingOptionalValue() {
        struct Test: Mappable {
            let string: String?
            init(mapper: Mapper) throws {
                self.string = mapper.map(optionalFrom: "whiskey")
            }
        }
        let test = try! Test(mapper: Mapper(structuredData: .null))
        XCTAssertNil(test.string)
    }

    func testMappingOptionalExisitngValue() {
        struct Test: Mappable {
            let string: String?
            init(mapper: Mapper) throws {
                string = mapper.map(optionalFrom: "whiskey")
            }
        }
        let test = try! Test(mapper: Mapper(structuredData: ["whiskey": "flows"]))
        XCTAssertEqual(test.string, "flows")
    }

    func testMappingOptionalArray() {
        struct Test: Mappable {
            let strings: [String]?
            init(mapper: Mapper) throws {
                self.strings = mapper.map(optionalArrayFrom: "whiskey")
            }
        }
        let test = try! Test(mapper: Mapper(structuredData: .null))
        XCTAssertNil(test.strings)
    }

    func testMappingOptionalExistingArray() {
        struct Test: Mappable {
            let strings: [String]?
            init(mapper: Mapper) throws {
                self.strings = mapper.map(optionalArrayFrom: "whiskey")
            }
        }
        let test = try! Test(mapper: Mapper(structuredData: ["whiskey": ["lera", "lynn"]]))
        XCTAssertEqual(test.strings!, ["lera", "lynn"])
    }
}
