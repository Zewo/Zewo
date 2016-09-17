import XCTest
@testable import Venice

public class CoroutineTests : XCTestCase {
    var sum: Int = 0

    func worker(count: Int, n: Int) {
        for _ in 0 ..< count {
            sum += n
            yield
        }
    }

    func testCo() {
        coroutine(self.worker(count: 3, n: 7))
        co(self.worker(count: 1, n: 11))
        co(self.worker(count: 2, n: 5))
        nap(for: 100.milliseconds)
        XCTAssert(sum == 42)
    }

    func testStackdeallocationWorks() {
        for _ in 0 ..< 20 {
            after(50.milliseconds) {}
        }
        nap(for: 100.milliseconds)
    }

    func testWakeUp() {
        let deadline = 100.milliseconds.fromNow()
        wake(at: deadline)
        let diff = now() - deadline
        XCTAssert(diff > -200 && diff < 200)
    }

    func testNap() {
        let channel = Channel<Double>()

        func delay(duration: Double) {
            nap(for: duration)
            channel.send(duration)
        }

        co(delay(duration: 30.milliseconds))
        co(delay(duration: 40.milliseconds))
        co(delay(duration: 10.milliseconds))
        co(delay(duration: 20.milliseconds))

        XCTAssert(channel.receive() == 10.milliseconds)
        XCTAssert(channel.receive() == 20.milliseconds)
        XCTAssert(channel.receive() == 30.milliseconds)
        XCTAssert(channel.receive() == 40.milliseconds)
    }

    func testFork() {
        _ = Venice.fork()
    }

    func testLogicalCPUCount() {
        XCTAssert(logicalCPUCount > 0)
    }

    func testDump() {
        Venice.dump()
    }

    func testEvery() {
        let channel = Channel<Void>()
        var counter = 0
        let period = 50.millisecond
        every(period) { done in
            counter += 1
            if counter == 3 {
                channel.send()
                done()
            }
        }
        let then = now()
        channel.receive()
        let diff = now() - then
        let threshold = 50.millisecond
        XCTAssert(diff > 3 * period - threshold && diff < 3 * period + threshold)
    }

    func testPollFileDescriptor() throws {
        var event: PollEvent
        var size: Int
        let fds = UnsafeMutablePointer<Int32>.allocate(capacity: 2)

        #if os(Linux)
            let result = socketpair(AF_UNIX, Int32(SOCK_STREAM.rawValue), 0, fds)
        #else
            let result = socketpair(AF_UNIX, SOCK_STREAM, 0, fds)
        #endif

        XCTAssert(result == 0)

        event = try poll(fds[0], events: .write)
        XCTAssert(event == .write)

        event = try poll(fds[0], events: .write, deadline: 100.milliseconds.fromNow())
        XCTAssert(event == .write)

        do {
            _ = try poll(fds[0], events: .read, deadline: 100.milliseconds.fromNow())
            XCTFail()
        } catch PollError.timeout {
            // yeah (:
        } catch {
            XCTFail()
        }

        size = send(fds[1], "A", 1, 0)
        XCTAssert(size == 1)
        event = try poll(fds[0], events: .write)
        XCTAssert(event == .write)

        event = try poll(fds[0], events: [.read, .write])
        XCTAssert(event == [.read, .write])

        var c: Int8 = 0
        size = recv(fds[0], &c, 1, 0)
        XCTAssert(size == 1)
        XCTAssert(c == 65)
    }

    func testSyncPerformanceVenice() {
        self.measure {
            let numberOfSyncs = 10000
            let channel = Channel<Void>()
            for _ in 0 ..< numberOfSyncs {
                co {
                    channel.send()
                }
                channel.receive()
            }
        }
    }

    func testManyCoroutines() {
        self.measure {
            let numberOfCoroutines = 10000
            for _ in 0 ..< numberOfCoroutines { co {} }
        }
    }

    func testThousandWhispers() {
        self.measure {
            func whisper(_ left: SendingChannel<Int>, _ right: ReceivingChannel<Int>) {
                left.send(1 + right.receive()!)
            }

            let numberOfWhispers = 10000

            let leftmost = Channel<Int>()
            var right = leftmost
            var left = leftmost

            for _ in 0 ..< numberOfWhispers {
                right = Channel<Int>()
                co(whisper(left.sendingChannel, right.receivingChannel))
                left = right
            }

            co(right.send(1))
            XCTAssert(leftmost.receive() == numberOfWhispers + 1)
        }
    }

    func testManyContextSwitches() {
        self.measure {
            let numberOfContextSwitches = 10000
            let count = numberOfContextSwitches / 2
            co {
                for _ in 0 ..< count {
                    yield
                }
            }
            for _ in 0 ..< count {
                yield
            }
        }
    }

    func testSendReceiveManyMessages() {
        self.measure {
            let numberOfMessages = 10000
            let channel = Channel<Int>(bufferSize: numberOfMessages)
            for _ in 0 ..< numberOfMessages {
                channel.send(0)
            }
            for _ in 0 ..< numberOfMessages {
                channel.receive()
            }
        }
    }

    func testManyRoundTrips() {
        self.measure {
            let numberOfRoundTrips = 10000
            let input = Channel<Int>()
            let output = Channel<Int>()
            let initiaValue = 1969
            var value = initiaValue
            co {
                while true {
                    let value = output.receive()!
                    input.send(value)
                }
            }
            for _ in 0 ..< numberOfRoundTrips {
                output.send(value)
                value = input.receive()!
            }
            XCTAssert(value == initiaValue)
        }
    }
}

extension CoroutineTests {
    public static var allTests: [(String, (CoroutineTests) -> () throws -> Void)] {
        return [
            ("testCo", testCo),
            ("testStackdeallocationWorks", testStackdeallocationWorks),
            ("testWakeUp", testWakeUp),
            ("testNap", testNap),
            ("testFork", testFork),
            ("testLogicalCPUCount", testLogicalCPUCount),
            ("testDump", testDump),
            ("testEvery", testEvery),
            ("testPollFileDescriptor", testPollFileDescriptor),
            ("testSyncPerformanceVenice", testSyncPerformanceVenice),
            ("testManyCoroutines", testManyCoroutines),
            ("testThousandWhispers", testThousandWhispers),
            ("testManyContextSwitches", testManyContextSwitches),
            ("testSendReceiveManyMessages", testSendReceiveManyMessages),
            ("testManyRoundTrips", testManyRoundTrips),
        ]
    }
}
