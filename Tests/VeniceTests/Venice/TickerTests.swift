import XCTest
@testable import Venice

public class TickerTests : XCTestCase {
    func testTicker() {
        let ticker = Ticker(period: 10.milliseconds)
        co {
            for _ in ticker.channel {}
        }
        nap(for: 100.milliseconds)
        ticker.stop()
        nap(for: 20.milliseconds)
    }
}

extension TickerTests {
    public static var allTests: [(String, (TickerTests) -> () throws -> Void)] {
        return [
            ("testTicker", testTicker),
        ]
    }
}
