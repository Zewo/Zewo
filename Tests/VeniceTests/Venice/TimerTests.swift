import XCTest
@testable import Venice

public class TimerTests : XCTestCase {
    func testTimer() {
        let timer = Timer(deadline: 100.milliseconds.fromNow())
        timer.channel.receive()
    }

    func testTimerStops() {
        let timer = Timer(deadline: 500.milliseconds.fromNow())
        co {
            timer.channel.receive()
        }
        XCTAssert(timer.stop() == true)
    }

    func testTimerStopsReturnFalse() {
        let deadline = 100.milliseconds.fromNow()
        let timer = Timer(deadline: deadline)
        co {
            timer.channel.receive()
        }
        wake(at: deadline + 500.milliseconds)
        XCTAssert(timer.stop() == false)
    }
}

extension TimerTests {
    public static var allTests: [(String, (TimerTests) -> () throws -> Void)] {
        return [
            ("testTimer", testTimer),
            ("testTimerStops", testTimerStops),
            ("testTimerStopsReturnFalse", testTimerStopsReturnFalse),
        ]
    }
}
