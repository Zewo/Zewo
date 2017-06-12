import XCTest
@testable import Core

public class StringTests : XCTestCase {
    func testCamelCaseSplit() {
        XCTAssertEqual("".camelCaseSplit(), [])
        XCTAssertEqual("lowercase".camelCaseSplit(), ["lowercase"])
        XCTAssertEqual("Class".camelCaseSplit(), ["Class"])
        XCTAssertEqual("MyClass".camelCaseSplit(), ["My", "Class"])
        XCTAssertEqual("MyC".camelCaseSplit(), ["My", "C"])
        XCTAssertEqual("HTML".camelCaseSplit(), ["HTML"])
        XCTAssertEqual("PDFLoader".camelCaseSplit(), ["PDF", "Loader"])
        XCTAssertEqual("AString".camelCaseSplit(), ["A", "String"])
        XCTAssertEqual("SimpleXMLParser".camelCaseSplit(), ["Simple", "XML", "Parser"])
        XCTAssertEqual("vimRPCPlugin".camelCaseSplit(), ["vim", "RPC", "Plugin"])
        XCTAssertEqual("GL11Version".camelCaseSplit(), ["GL", "11", "Version"])
        XCTAssertEqual("99Bottles".camelCaseSplit(), ["99", "Bottles"])
        XCTAssertEqual("May5".camelCaseSplit(), ["May", "5"])
        XCTAssertEqual("BFG9000".camelCaseSplit(), ["BFG", "9000"])
        XCTAssertEqual("BöseÜberraschung".camelCaseSplit(), ["Böse", "Überraschung"])
        XCTAssertEqual("Two  spaces".camelCaseSplit(), ["Two", "  ", "spaces"])
    }
    
    public static var allTests = [
        ("testCamelCaseSplit", testCamelCaseSplit),
    ]
}
