import XCTest
import Media
import HTTP

struct Todo : MediaCodable {
    let id: Int
    let userId: Int
    let title: String
    let completed: Bool
}

public class ClientTests : XCTestCase {
    func testClient() throws {
        let client = try Client(uri: "http://jsonplaceholder.typicode.com")
        let request = try Request(method: .get, uri: "/todos/1")
        let response = try client.send(request)
        let todo: Todo = try response.content()
        
        XCTAssertEqual(todo.id, 1)
        XCTAssertEqual(todo.userId, 1)
        XCTAssertEqual(todo.title, "delectus aut autem")
        XCTAssertEqual(todo.completed, false)
    }
}

extension ClientTests {
    public static var allTests: [(String, (ClientTests) -> () throws -> Void)] {
        return [
            ("testClient", testClient),
        ]
    }
}
