import XCTest
@testable import Core
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
    
    func testParser() throws {
        let string =
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + "\n" +
        "<ListAllMyBucketsResult xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\"><Owner><ID>cb9bfdc6ad55baa411a245bd9cf2ab7d2504663a95bb21f4e8268d33d9848039</ID><DisplayName>fabiogutierrez</DisplayName></Owner><Buckets><Bucket><Name>pixeoh-api</Name><CreationDate>2017-02-24T17:40:21.000Z</CreationDate></Bucket><Bucket><Name>pixeoh-api-staging</Name><CreationDate>2017-03-02T00:36:52.000Z</CreationDate></Bucket></Buckets></ListAllMyBucketsResult>"
        
//        let xml = try XMLParser.parse(string.data(using: .utf8)!, deadline: 1.minute.fromNow())
//        print(xml)
    }
}



extension XMLTests {
    public static var allTests: [(String, (XMLTests) -> () throws -> Void)] {
        return [
            ("testXML", testXML),
        ]
    }
}
