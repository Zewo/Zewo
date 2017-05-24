import XCTest
@testable import Content
import Foundation

public class XMLTests: XCTestCase {
    func testXML() throws {
        let xml = XML(name: "Root", children: [
            XML(name: "Catalog", children: [
                XML(name: "Book", attributes: ["id": "a"], children: [
                    XML(name: "Author", children: ["Bob"]),
                ]),
                XML(name: "Book", attributes: ["id": "b"], children: [
                    XML(name: "Author", children: ["John"]),
                ]),
                XML(name: "Book", attributes: ["id": "c"], children: [
                    XML(name: "Author", children: ["Mark"]),
                ]),
            ]),
        ])
        
        try print(xml.get("Catalog", "Book", 1, "Author").content)
        try print(xml.get("Catalog", 0, "Book", 1, "Author", 0).content)
        try print(xml.get("Catalog", "Book", 1).getAttribute("id") ?? "nope")
        try print(xml.get("Catalog", "Book").withAttribute("id", equalTo: "b")?.get("Author").content ?? "nope")
        
        for element in try xml.get("Catalog", "Book") {
            try print(element.get("Author").content)
        }
    }
}



extension XMLTests {
    public static var allTests: [(String, (XMLTests) -> () throws -> Void)] {
        return [
            ("testXML", testXML),
        ]
    }
}
