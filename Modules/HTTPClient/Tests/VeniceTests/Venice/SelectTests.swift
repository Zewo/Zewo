import XCTest
@testable import Venice

public class SelectTests : XCTestCase {
    func testNonBlockingReceiver() {
        let channel = Channel<Int>()
        co {
            channel.send(555)
        }
        sel { when in
            when.receive(from: channel) { value in
                XCTAssert(value == 555)
            }
        }
    }

    func testBlockingReceiver() {
        let channel = Channel<Int>()
        co {
            yield
            channel.send(666)
        }
        sel { when in
            when.receive(from: channel) { value in
                XCTAssert(value == 666)
            }
        }
    }

    func testNonBlockingSender() {
        let channel = Channel<Int>()
        co {
            let value = channel.receive()
            XCTAssert(value == 777)
        }
        sel { when in
            when.send(777, to: channel) {}
        }
    }

    func testBlockingSender() {
        let channel = Channel<Int>()
        co {
            yield
            XCTAssert(channel.receive() == 888)
        }
        sel { when in
            when.send(888, to: channel) {}
        }
    }

    func testTwoChannels() {
        let channel1 = Channel<Int>()
        let channel2 = Channel<Int>()
        co {
            channel1.send(555)
        }
        sel { when in
            when.receive(from: channel1) { value in
                XCTAssert(value == 555)
            }
            when.receive(from: channel2) { value in
                XCTAssert(false)
            }
        }
        co {
            yield
            channel2.send(666)
        }
        sel { when in
            when.receive(from: channel1) { value in
                XCTAssert(false)
            }
            when.receive(from: channel2) { value in
                XCTAssert(value == 666)
            }
        }
    }

    func testReceiveRandomChannelSelection() {
        let channel1 = Channel<Int>()
        let channel2 = Channel<Int>()
        co {
            while true {
                channel1.send(111)
                yield
            }
        }
        co {
            while true {
                channel2.send(222)
                yield
            }
        }
        var first = 0
        var second = 0
        for _ in 0 ..< 100 {
            sel { when in
                when.receive(from: channel1) { value in
                    XCTAssert(value == 111)
                    first += 1
                }
                when.receive(from: channel2) { value in
                    XCTAssert(value == 222)
                    second += 1
                }
            }
            yield
        }
        XCTAssert(first > 1 && second > 1)
    }

    func testSendRandomChannelSelection() {
        let channel = Channel<Int>()
        co {
            while true {
                sel { when in
                    when.send(666, to: channel) {}
                    when.send(777, to: channel) {}
                }
            }
        }
        var first = 0
        var second = 0
        for _ in 0 ..< 100 {
            let value = channel.receive()
            if value == 666 {
                first += 1
            } else if value == 777 {
                second += 1
            } else {
                XCTAssert(false)
            }

        }
        XCTAssert(first > 1 && second > 1)
    }

    func testOtherwise() {
        let channel = Channel<Int>()
        var test = 0
        sel { when in
            when.receive(from: channel) { value in
                XCTAssert(false)
            }
            when.otherwise {
                test = 1
            }
        }
        XCTAssert(test == 1)
        test = 0
        sel { when in
            when.otherwise {
                test = 1
            }
        }
        XCTAssert(test == 1)
    }

    func testTwoSimultaneousSenders() {
        let channel = Channel<Int>()
        co {
            channel.send(888)
        }
        co {
            channel.send(999)
        }
        var value = 0
        sel { when in
            when.receive(from: channel) { v in
                value = v
            }
        }
        XCTAssert(value == 888)
        value = 0
        sel { when in
            when.receive(from: channel) { v in
                value = v
            }
        }
        XCTAssert(value == 999)
    }

    func testTwoSimultaneousReceivers() {
        let channel = Channel<Int>()
        co {
            XCTAssert(channel.receive() == 333)
        }
        co {
            XCTAssert(channel.receive() == 444)
        }
        sel { when in
            when.send(333, to: channel) {}
        }
        sel { when in
            when.send(444, to: channel) {}
        }
    }

    func testSelectWithSelect() {
        let channel = Channel<Int>()
        co {
            sel { when in
                when.send(111, to: channel) {}
            }
        }
        sel { when in
            when.receive(from: channel) { value in
                XCTAssert(value == 111)
            }
        }
    }

    func testSelectWithBufferedChannels() {
        let channel = Channel<Int>(bufferSize: 1)
        sel { when in
            when.send(999, to: channel) {}
        }
        sel { when in
            when.receive(from: channel) { value in
                XCTAssert(value == 999)
            }
        }
    }

    func testReceiveSelectFromClosedChannel() {
        let channel = Channel<Int>()
        channel.close()
        sel { when in
            when.receive(from: channel) { value in
                XCTAssert(false)
            }
        }
    }

    func testRandomReceiveSelectionWhenNothingImmediatelyAvailable() {
        let channel = Channel<Int>()
        co {
            while true {
                nap(for: 1.millisecond)
                channel.send(333)
            }
        }
        var first = 0
        var second = 0
        var third = 0
        for _ in 0 ..< 100 {
            sel { when in
                when.receive(from: channel) { value in
                    first += 1
                }
                when.receive(from: channel) { value in
                    second += 1
                }
                when.receive(from: channel) { value in
                    third += 1
                }
            }
        }
        XCTAssert(first > 1 && second > 1 && third > 1)
    }

    func testRandomSendSelectionWhenNothingImmediatelyAvailable() {
        let channel = Channel<Int>()
        co {
            while true {
                sel { when in
                    when.send(1, to: channel) {}
                    when.send(2, to: channel) {}
                    when.send(3, to: channel) {}
                }
            }
        }
        var first = 0
        var second = 0
        var third = 0
        for _ in 0 ..< 100 {
            nap(for: 1.millisecond)
            let value = channel.receive()!
            switch value {
            case 1: first += 1
            case 2: second += 1
            case 3: third += 1
            default: XCTAssert(false)
            }

        }
        XCTAssert(first > 1 && second > 1 && third > 1)
    }

    func testReceivingFromSendingChannel() {
        let channel = Channel<Int>()
        co {
            channel.send(555)
        }
        sel { when in
            when.receive(from: channel.receivingChannel) { value in
                XCTAssert(value == 555)
            }
        }
    }

    func testReceivingFromFallibleChannel() {
        let channel = FallibleChannel<Int>()
        co {
            channel.send(555)
        }
        sel { when in
            when.receive(from: channel) { result in
                var value = 0
                result.success { v in
                    value = v
                }
                XCTAssert(value == 555)
            }
        }
    }

    func testReceivingErrorFromFallibleChannel() {
        let channel = FallibleChannel<Int>()
        co {
            channel.send(SomeError())
        }
        sel { when in
            when.receive(from: channel) { result in
                var error: Error? = nil
                result.failure { e in
                    error = e
                }
                XCTAssert(error is SomeError)
            }
        }
    }

    func testReceivingFromFallibleSendingChannel() {
        let channel = FallibleChannel<Int>()
        co {
            channel.send(555)
        }
        sel { when in
            when.receive(from: channel.receivingChannel) { result in
                var value = 0
                result.success { v in
                    value = v
                }
                XCTAssert(value == 555)
            }
        }
    }

    func testReceivingErrorFromFallibleSendingChannel() {
        let channel = FallibleChannel<Int>()
        co {
            channel.send(SomeError())
        }
        sel { when in
            when.receive(from: channel.receivingChannel) { result in
                var error: Error? = nil
                result.failure { e in
                    error = e
                }
                XCTAssert(error is SomeError)
            }
        }
    }

    func testSendingToReceivingChannel() {
        let channel = Channel<Int>()
        co {
            let value = channel.receive()
            XCTAssert(value == 777)
        }
        sel { when in
            when.send(777, to: channel.sendingChannel) {}
        }
    }

    func testSendingToFallibleChannel() {
        let channel = FallibleChannel<Int>()
        co {
            let value = try! channel.receive()
            XCTAssert(value == 777)
        }
        sel { when in
            when.send(777, to: channel) {}
        }
    }

    func testThrowingErrorIntoFallibleChannel() {
        let channel = FallibleChannel<Int>()
        co {
            self.assert(channel: channel, catchesErrorOfType: SomeError.self)
        }
        sel { when in
            when.send(SomeError(), to: channel) {}
        }
    }

    func testSendingToFallibleReceivingChannel() {
        let channel = FallibleChannel<Int>()
        co {
            let value = try! channel.receive()
            XCTAssert(value == 777)
        }
        sel { when in
            when.send(777, to: channel.sendingChannel) {}
        }
    }

    func testThrowingErrorIntoFallibleReceivingChannel() {
        let channel = FallibleChannel<Int>()
        co {
            self.assert(channel: channel, catchesErrorOfType: SomeError.self)
        }
        sel { when in
            when.send(SomeError(), to: channel.sendingChannel) {}
        }
    }

    func testTimeout() {
        var timedout = false
        sel { when in
            when.timeout(10.millisecond.fromNow()) {
                timedout = true
            }
        }
        XCTAssert(timedout)
    }

    func testForSelect() {
        let channel = Channel<Int>()
        after(10.milliseconds) {
            channel.send(444)
        }
        after(20.milliseconds) {
            channel.send(444)
        }
        var count = 0
        forSel { when, done in
            when.receive(from: channel) { value in
                XCTAssert(value == 444)
                count += 1
                if count == 2 {
                    done()
                }
            }
        }
    }
}

extension SelectTests {
    func assert<T, E>(channel: FallibleChannel<T>, catchesErrorOfType type: E.Type) {
        var thrown = false
        do {
            try channel.receive()
        } catch _ as E {
            thrown = true
        } catch {}
        XCTAssert(thrown)
    }

    func assert<T, E>(channel: FallibleReceivingChannel<T>, catchesErrorOfType type: E.Type) {
        var thrown = false
        do {
            try channel.receive()
        } catch _ as E {
            thrown = true
        } catch {}
        XCTAssert(thrown)
    }
}

extension SelectTests {
    public static var allTests: [(String, (SelectTests) -> () throws -> Void)] {
        return [
            ("testNonBlockingReceiver", testNonBlockingReceiver),
            ("testBlockingReceiver", testBlockingReceiver),
            ("testNonBlockingSender", testNonBlockingSender),
            ("testBlockingSender", testBlockingSender),
            ("testTwoChannels", testTwoChannels),
            ("testReceiveRandomChannelSelection", testReceiveRandomChannelSelection),
            ("testSendRandomChannelSelection", testSendRandomChannelSelection),
            ("testOtherwise", testOtherwise),
            ("testTwoSimultaneousSenders", testTwoSimultaneousSenders),
            ("testTwoSimultaneousReceivers", testTwoSimultaneousReceivers),
            ("testSelectWithSelect", testSelectWithSelect),
            ("testSelectWithBufferedChannels", testSelectWithBufferedChannels),
            ("testReceiveSelectFromClosedChannel", testReceiveSelectFromClosedChannel),
            ("testRandomReceiveSelectionWhenNothingImmediatelyAvailable", testRandomReceiveSelectionWhenNothingImmediatelyAvailable),
            ("testRandomSendSelectionWhenNothingImmediatelyAvailable", testRandomSendSelectionWhenNothingImmediatelyAvailable),
            ("testReceivingFromSendingChannel", testReceivingFromSendingChannel),
            ("testReceivingFromFallibleChannel", testReceivingFromFallibleChannel),
            ("testReceivingErrorFromFallibleChannel", testReceivingErrorFromFallibleChannel),
            ("testReceivingFromFallibleSendingChannel", testReceivingFromFallibleSendingChannel),
            ("testReceivingErrorFromFallibleSendingChannel", testReceivingErrorFromFallibleSendingChannel),
            ("testSendingToReceivingChannel", testSendingToReceivingChannel),
            ("testSendingToFallibleChannel", testSendingToFallibleChannel),
            ("testThrowingErrorIntoFallibleChannel", testThrowingErrorIntoFallibleChannel),
            ("testSendingToFallibleReceivingChannel", testSendingToFallibleReceivingChannel),
            ("testThrowingErrorIntoFallibleReceivingChannel", testThrowingErrorIntoFallibleReceivingChannel),
            ("testTimeout", testTimeout),
            ("testForSelect", testForSelect),
        ]
    }
}
