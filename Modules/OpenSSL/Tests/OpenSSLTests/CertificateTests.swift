import XCTest
@testable import OpenSSL

public class CertificateTests : XCTestCase {
    func testRand() throws {
        let key = Key.generate(keyLength: 2048)
        let cn = "example.com"

        _ = try Certificate(privateKey:key, commonName:cn)

        let first = Random.number()
        let second = Random.number()

        XCTAssert(
            first != second,
            "Two successive random numbers really shouldn't be the same"
        )
    }
}

extension CertificateTests {
    public static var allTests: [(String, (CertificateTests) -> () throws -> Void)] {
        return [
            ("testRand", testRand),
        ]
    }
}
