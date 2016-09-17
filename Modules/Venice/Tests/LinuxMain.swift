import XCTest
@testable import VeniceTests

XCTMain([
    testCase(ChannelTests.allTests),
    testCase(CoroutineTests.allTests),
    testCase(FallibleChannelTests.allTests),
    testCase(SelectTests.allTests),
    testCase(TickerTests.allTests),
    testCase(TimerTests.allTests),
])
