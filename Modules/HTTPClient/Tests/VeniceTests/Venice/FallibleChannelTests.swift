import XCTest
@testable import Venice

struct SomeError : Error {}
struct NastyError : Error {}

public class FallibleChannelTests : XCTestCase {
    func testReceiverWaitsForSender() {
        let channel = FallibleChannel<Int>()
        co {
            yield
            channel.send(333)
        }
        XCTAssert(try channel.receive() == 333)
    }

    func testReceiverWaitsForSenderError() {
        let channel = FallibleChannel<Int>()
        co {
            yield
            channel.send(SomeError())
        }
        assert(channel: channel, catchesErrorOfType: SomeError.self)
    }

    func testSenderWaitsForReceiver() {
        let channel = FallibleChannel<Int>()
        co {
            channel.send(444)
        }
        XCTAssert(try channel.receive() == 444)
    }

    func testSenderWaitsForReceiverError() {
        let channel = FallibleChannel<Int>()
        co {
            channel.send(SomeError())
        }
        assert(channel: channel, catchesErrorOfType: SomeError.self)
    }

    func testSendingChannel() {
        let channel = FallibleChannel<Int>()
        func send(_ channel: FallibleSendingChannel<Int>) {
            channel.send(888)
        }
        co(send(channel.sendingChannel))
        XCTAssert(try channel.receive() == 888)
    }

    func testSendingChannelError() {
        let channel = FallibleChannel<Int>()
        func send(_ channel: FallibleSendingChannel<Int>) {
            channel.send(SomeError())
        }
        co(send(channel.sendingChannel))
        assert(channel: channel, catchesErrorOfType: SomeError.self)
    }

    func testReceivingChannel() {
        let channel = FallibleChannel<Int>()
        func receive(_ channel: FallibleReceivingChannel<Int>) {
            XCTAssert(try channel.receive() == 999)
        }
        co{
            channel.send(999)
        }
        receive(channel.receivingChannel)
    }

    func testReceivingChannelError() {
        let channel = FallibleChannel<Int>()
        func receive(_ channel: FallibleReceivingChannel<Int>) {
            assert(channel: channel, catchesErrorOfType: SomeError.self)
        }
        co{
            channel.send(SomeError())
        }
        receive(channel.receivingChannel)
    }

    func testTwoSimultaneousSenders() {
        let channel = FallibleChannel<Int>()
        co {
            channel.send(888)
        }
        co {
            channel.send(999)
        }
        XCTAssert(try channel.receive() == 888)
        yield
        XCTAssert(try channel.receive() == 999)
    }

    func testTwoSimultaneousSendersError() {
        let channel = FallibleChannel<Int>()
        co {
            channel.send(SomeError())
        }
        co {
            channel.send(NastyError())
        }
        assert(channel: channel, catchesErrorOfType: SomeError.self)
        yield
        assert(channel: channel, catchesErrorOfType: NastyError.self)
    }

    func testTwoSimultaneousReceivers() {
        let channel = FallibleChannel<Int>()
        co {
            XCTAssert(try! channel.receive() == 333)
        }
        co {
            XCTAssert(try! channel.receive() == 444)
        }
        channel.send(333)
        channel.send(444)
    }

    func testTwoSimultaneousReceiversError() {
        let channel = FallibleChannel<Int>()
        co {
            self.assert(channel: channel, catchesErrorOfType: SomeError.self)
        }
        co {
            self.assert(channel: channel, catchesErrorOfType: NastyError.self)
        }
        channel.send(SomeError())
        channel.send(NastyError())
    }

    func testTypedChannels() throws {
        let stringChannel = FallibleChannel<String>()
        co {
            stringChannel.send("yo")
        }
        XCTAssert(try stringChannel.receive() == "yo")

        struct Foo { let bar: Int; let baz: Int }

        let fooChannel = FallibleChannel<Foo>()
        co {
            fooChannel.send(Foo(bar: 555, baz: 222))
        }
        let foo = try fooChannel.receive()
        XCTAssert(foo?.bar == 555 && foo?.baz == 222)
    }

    func testTypedChannelsError() {
        let stringChannel = FallibleChannel<String>()
        co {
            stringChannel.send(SomeError())
        }
        assert(channel: stringChannel, catchesErrorOfType: SomeError.self)

        struct Foo { let bar: Int; let baz: Int }

        let fooChannel = FallibleChannel<Foo>()
        co {
            fooChannel.send(NastyError())
        }
        assert(channel: fooChannel, catchesErrorOfType: NastyError.self)
    }

    func testMessageBuffering() {
        let channel = FallibleChannel<Int>(bufferSize: 2)
        channel.send(222)
        channel.send(333)
        XCTAssert(try channel.receive() == 222)
        XCTAssert(try channel.receive() == 333)
        channel.send(444)
        XCTAssert(try channel.receive() == 444)
        channel.send(555)
        channel.send(666)
        XCTAssert(try channel.receive() == 555)
        XCTAssert(try channel.receive() == 666)
    }

    func testMessageBufferingError() {
        let channel = FallibleChannel<Int>(bufferSize: 2)
        channel.send(SomeError())
        channel.send(NastyError())
        assert(channel: channel, catchesErrorOfType: SomeError.self)
        assert(channel: channel, catchesErrorOfType: NastyError.self)
        channel.send(SomeError())
        assert(channel: channel, catchesErrorOfType: SomeError.self)
        channel.send(SomeError())
        channel.send(NastyError())
        assert(channel: channel, catchesErrorOfType: SomeError.self)
        assert(channel: channel, catchesErrorOfType: NastyError.self)
    }

    func testSimpleChannelClose() {
        let channel1 = FallibleChannel<Int>()
        channel1.close()
        XCTAssert(try channel1.receive() == nil)
        XCTAssert(try channel1.receive() == nil)
        XCTAssert(try channel1.receive() == nil)

        let channel2 = FallibleChannel<Int>(bufferSize: 10)
        channel2.close()
        XCTAssert(try channel2.receive() == nil)
        XCTAssert(try channel2.receive() == nil)
        XCTAssert(try channel2.receive() == nil)

        let channel3 = FallibleChannel<Int>(bufferSize: 10)
        channel3.send(999)
        channel3.close()
        XCTAssert(try channel3.receive() == 999)
        XCTAssert(try channel3.receive() == nil)
        XCTAssert(try channel3.receive() == nil)

        let channel4 = FallibleChannel<Int>(bufferSize: 1)
        channel4.send(222)
        channel4.close()
        XCTAssert(try channel4.receive() == 222)
        XCTAssert(try channel4.receive() == nil)
        XCTAssert(try channel4.receive() == nil)
    }


    func testSimpleChannelCloseError() {
        let channel1 = FallibleChannel<Int>()
        channel1.close()
        XCTAssert(try channel1.receive() == nil)
        XCTAssert(try channel1.receive() == nil)
        XCTAssert(try channel1.receive() == nil)

        let channel2 = FallibleChannel<Int>(bufferSize: 10)
        channel2.close()
        XCTAssert(try channel2.receive() == nil)
        XCTAssert(try channel2.receive() == nil)
        XCTAssert(try channel2.receive() == nil)

        let channel3 = FallibleChannel<Int>(bufferSize: 10)
        channel3.send(SomeError())
        channel3.close()
        assert(channel: channel3, catchesErrorOfType: SomeError.self)
        XCTAssert(try channel3.receive() == nil)
        XCTAssert(try channel3.receive() == nil)

        let channel4 = FallibleChannel<Int>(bufferSize: 1)
        channel4.send(NastyError())
        channel4.close()
        assert(channel: channel4, catchesErrorOfType: NastyError.self)
        XCTAssert(try channel4.receive() == nil)
        XCTAssert(try channel4.receive() == nil)
    }

    func testChannelCloseUnblocks() {
        let channel1 = FallibleChannel<Int>()
        let channel2 = FallibleChannel<Int>()
        co {
            XCTAssert(try! channel1.receive() == nil)
            channel2.send(0)
        }
        co {
            XCTAssert(try! channel1.receive() == nil)
            channel2.send(0)
        }
        channel1.close()
        XCTAssert(try channel2.receive() == 0)
        XCTAssert(try channel2.receive() == 0)
    }

    func testChannelCloseUnblocksError() {
        let channel1 = FallibleChannel<Int>()
        let channel2 = FallibleChannel<Int>()
        co {
            XCTAssert(try! channel1.receive() == nil)
            channel2.send(SomeError())
        }
        co {
            XCTAssert(try! channel1.receive() == nil)
            channel2.send(NastyError())
        }
        channel1.close()
        assert(channel: channel2, catchesErrorOfType: SomeError.self)
        assert(channel: channel2, catchesErrorOfType: NastyError.self)
    }

    func testBlockedSenderAndItemInTheChannel() {
        let channel = FallibleChannel<Int>(bufferSize: 1)
        channel.send(1)
        co {
            channel.send(2)
        }
        XCTAssert(try channel.receive() == 1)
        XCTAssert(try channel.receive() == 2)
    }

    func testBlockedSenderAndItemInTheError() {
        let channel = FallibleChannel<Int>(bufferSize: 1)
        channel.send(SomeError())
        co {
            channel.send(NastyError())
        }
        assert(channel: channel, catchesErrorOfType: SomeError.self)
        assert(channel: channel, catchesErrorOfType: NastyError.self)
    }

    func testPanicWhenSendingToChannelDeadlocks() {
        // let pid = mill_fork()
        // XCTAssert(pid >= 0)
        // if pid == 0 {
        //     alarm(1)
        //     let channel = FallibleChannel<Int>()
        //     signal(SIGABRT) { _ in
        //         _exit(0)
        //     }
        //     channel.send(42)
        //     XCTFail()
        // }
        // var exitCode: Int32 = 0
        // XCTAssert(waitpid(pid, &exitCode, 0) != 0)
        // XCTAssert(exitCode == 0)
    }

    func testPanicWhenSendingToChannelDeadlocksError() {
        // let pid = mill_fork()
        // XCTAssert(pid >= 0)
        // if pid == 0 {
        //     alarm(1)
        //     let channel = FallibleChannel<Int>()
        //     signal(SIGABRT) { _ in
        //         _exit(0)
        //     }
        //     channel.send(Error())
        //     XCTFail()
        // }
        // var exitCode: Int32 = 0
        // XCTAssert(waitpid(pid, &exitCode, 0) != 0)
        // XCTAssert(exitCode == 0)
    }

    func testPanicWhenReceivingFromChannelDeadlocks() {
        // let pid = mill_fork()
        // XCTAssert(pid >= 0)
        // if pid == 0 {
        //     alarm(1)
        //     let channel = FallibleChannel<Int>()
        //     signal(SIGABRT) { _ in
        //         _exit(0)
        //     }
        //     try channel.receive()
        //     XCTFail()
        // }
        // var exitCode: Int32 = 0
        // XCTAssert(waitpid(pid, &exitCode, 0) != 0)
        // XCTAssert(exitCode == 0)
    }

    func testChannelIteration() {
        let channel =  FallibleChannel<Int>(bufferSize: 2)
        channel.send(555)
        channel.send(555)
        channel.close()
        for result in channel {
            var value = 0
            result.success { v in
                value = v
            }
            result.failure { _ in
                XCTAssert(false)
            }
            XCTAssert(value == 555)
        }
    }

    func testChannelIterationError() {
        let channel =  FallibleChannel<Int>(bufferSize: 2)
        channel.send(SomeError())
        channel.send(SomeError())
        channel.close()
        for result in channel {
            var error: Error? = nil
            result.failure { e in
                error = e
            }
            result.success { _ in
                XCTAssert(false)
            }
            XCTAssert(error is SomeError)
        }
    }

    func testReceivingChannelIteration() {
        let channel =  FallibleChannel<Int>(bufferSize: 2)
        channel.send(444)
        channel.send(444)
        func receive(_ channel: FallibleReceivingChannel<Int>) {
            channel.close()
            for result in channel {
                var value = 0
                result.success { v in
                    value = v
                }
                XCTAssert(value == 444)
            }
        }
        receive(channel.receivingChannel)
    }

    func testReceivingChannelIterationError() {
        let channel =  FallibleChannel<Int>(bufferSize: 2)
        channel.send(SomeError())
        channel.send(SomeError())
        func receive(_ channel: FallibleReceivingChannel<Int>) {
            channel.close()
            for result in channel {
                var error: Error? = nil
                result.failure { e in
                    error = e
                }
                XCTAssert(error is SomeError)
            }
        }
        receive(channel.receivingChannel)
    }

    func testReceiveResult() {
        let channel = FallibleChannel<Int>(bufferSize: 1)
        co {
            channel.sendingChannel.send(.value(333))
        }
        XCTAssert(try channel.receive() == 333)
    }

}

extension FallibleChannelTests {
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

extension FallibleChannelTests {
    public static var allTests: [(String, (FallibleChannelTests) -> () throws -> Void)] {
        return [
            ("testReceiverWaitsForSender", testReceiverWaitsForSender),
            ("testReceiverWaitsForSenderError", testReceiverWaitsForSenderError),
            ("testSenderWaitsForReceiver", testSenderWaitsForReceiver),
            ("testSenderWaitsForReceiverError", testSenderWaitsForReceiverError),
            ("testSendingChannel", testSendingChannel),
            ("testSendingChannelError", testSendingChannelError),
            ("testReceivingChannel", testReceivingChannel),
            ("testReceivingChannelError", testReceivingChannelError),
            ("testTwoSimultaneousSenders", testTwoSimultaneousSenders),
            ("testTwoSimultaneousSendersError", testTwoSimultaneousSendersError),
            ("testTwoSimultaneousReceivers", testTwoSimultaneousReceivers),
            ("testTwoSimultaneousReceiversError", testTwoSimultaneousReceiversError),
            ("testTypedChannels", testTypedChannels),
            ("testTypedChannelsError", testTypedChannelsError),
            ("testMessageBuffering", testMessageBuffering),
            ("testMessageBufferingError", testMessageBufferingError),
            ("testSimpleChannelClose", testSimpleChannelClose),
            ("testSimpleChannelCloseError", testSimpleChannelCloseError),
            ("testChannelCloseUnblocks", testChannelCloseUnblocks),
            ("testChannelCloseUnblocksError", testChannelCloseUnblocksError),
            ("testBlockedSenderAndItemInTheChannel", testBlockedSenderAndItemInTheChannel),
            ("testBlockedSenderAndItemInTheError", testBlockedSenderAndItemInTheError),
            ("testPanicWhenSendingToChannelDeadlocks", testPanicWhenSendingToChannelDeadlocks),
            ("testPanicWhenSendingToChannelDeadlocksError", testPanicWhenSendingToChannelDeadlocksError),
            ("testPanicWhenReceivingFromChannelDeadlocks", testPanicWhenReceivingFromChannelDeadlocks),
            ("testChannelIteration", testChannelIteration),
            ("testChannelIterationError", testChannelIterationError),
            ("testReceivingChannelIteration", testReceivingChannelIteration),
            ("testReceivingChannelIterationError", testReceivingChannelIterationError),
            ("testReceiveResult", testReceiveResult),
        ]
    }
}
