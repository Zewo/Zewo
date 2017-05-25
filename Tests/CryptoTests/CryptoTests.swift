import XCTest
import Crypto

public class CryptoTests: XCTestCase {
    func testCrypto() throws {
        print(Crypto.argon2(password: "password", salt: "somesalt"))
    }
}

extension CryptoTests {
    public static var allTests: [(String, (CryptoTests) -> () throws -> Void)] {
        return [
            ("testCrypto", testCrypto),
        ]
    }
}
