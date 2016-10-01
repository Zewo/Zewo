import XCTest
@testable import HTTP

public class BodyTests : XCTestCase {
    let testData = Buffer([0x00, 0x01, 0x02, 0x03])

    func testBufferBecomeBuffer() throws {
        var body: Body = .buffer(testData)
        let buffer = try body.becomeBuffer(deadline: 1.second.fromNow())
        XCTAssertTrue(body.isBuffer)
        XCTAssertFalse(body.isReader)
        XCTAssertFalse(body.isWriter)
        XCTAssertEqual(buffer, testData)
        switch body {
        case .buffer(let data):
            XCTAssertEqual(data, self.testData)
        default:
            XCTFail()
        }
    }

    func testBufferBecomeReader() throws {
        var body: Body = .buffer(testData)
        let reader = try body.becomeReader()
        XCTAssertFalse(body.isBuffer)
        XCTAssertTrue(body.isReader)
        XCTAssertFalse(body.isWriter)
        XCTAssertFalse(reader.closed)
        let buffer = try reader.read(upTo: testData.count, deadline: 1.second.fromNow())
        XCTAssertFalse(reader.closed)
        XCTAssertEqual(buffer.count, testData.count)
        XCTAssertEqual(buffer, testData)
    }

    func testBufferBecomeWriter() throws {
        var body: Body = .buffer(testData)
        let writer = try body.becomeWriter(deadline: 1.second.fromNow())
        let writerStream = BufferStream()
        try writer(writerStream)
        XCTAssertFalse(body.isBuffer)
        XCTAssertFalse(body.isReader)
        XCTAssertTrue(body.isWriter)
        XCTAssertFalse(writerStream.closed)
        let buffer = try writerStream.read(upTo: testData.count, deadline: 1.second.fromNow())
        XCTAssertFalse(writerStream.closed)
        XCTAssertEqual(buffer.count, testData.count)
        XCTAssertEqual(buffer, testData)
    }

    func testReaderBecomeBuffer() throws {
        let readerSteram = BufferStream(buffer: testData)
        var body: Body = .reader(readerSteram)
        let buffer = try body.becomeBuffer(deadline: 1.second.fromNow())
        XCTAssertTrue(body.isBuffer)
        XCTAssertFalse(body.isReader)
        XCTAssertFalse(body.isWriter)
        XCTAssertEqual(buffer, testData)
        switch body {
        case .buffer(let data):
            XCTAssertEqual(data, self.testData)
        default:
            XCTFail()
        }
    }

    func testReaderBecomeReader() throws {
        let readerSteram = BufferStream(buffer: testData)
        var body: Body = .reader(readerSteram)
        let reader = try body.becomeReader()
        XCTAssertFalse(body.isBuffer)
        XCTAssertTrue(body.isReader)
        XCTAssertFalse(body.isWriter)
        XCTAssertFalse(reader.closed)
        let buffer = try reader.read(upTo: testData.count, deadline: 1.second.fromNow())
        XCTAssertFalse(reader.closed)
        XCTAssertEqual(buffer.count, testData.count)
        XCTAssertEqual(buffer, testData)
    }

    func testReaderBecomeWriter() throws {
        let readerSteram = BufferStream(buffer: testData)
        var body: Body = .reader(readerSteram)
        let writer = try body.becomeWriter(deadline: 1.second.fromNow())
        let writerStream = BufferStream()
        try writer(writerStream)
        XCTAssertFalse(body.isBuffer)
        XCTAssertFalse(body.isReader)
        XCTAssertTrue(body.isWriter)
        XCTAssertFalse(writerStream.closed)
        let buffer = try writerStream.read(upTo: testData.count, deadline: 1.second.fromNow())
        XCTAssertFalse(writerStream.closed)
        XCTAssertEqual(buffer.count, testData.count)
        XCTAssertEqual(buffer, testData)
    }

    func testWriterBecomeBuffer() throws {
        var body: Body = .writer { writerStream in
            try writerStream.write(self.testData, deadline: 1.second.fromNow())
            try writerStream.flush(deadline: 1.second.fromNow())
        }
        let buffer = try body.becomeBuffer(deadline: 1.second.fromNow())
        XCTAssertTrue(body.isBuffer)
        XCTAssertFalse(body.isReader)
        XCTAssertFalse(body.isWriter)
        XCTAssertEqual(buffer, testData)
        switch body {
        case .buffer(let data):
            XCTAssertEqual(data, self.testData)
        default:
            XCTFail()
        }
    }

    func testWriterBecomeReader() throws {
        var body: Body = .writer { writerStream in
            try writerStream.write(self.testData, deadline: 1.second.fromNow())
            try writerStream.flush(deadline: 1.second.fromNow())
        }
        let reader = try body.becomeReader()
        XCTAssertFalse(body.isBuffer)
        XCTAssertTrue(body.isReader)
        XCTAssertFalse(body.isWriter)
        XCTAssertFalse(reader.closed)
        let buffer = try reader.read(upTo: testData.count, deadline: 1.second.fromNow())
        XCTAssertFalse(reader.closed)
        XCTAssertEqual(buffer.count, testData.count)
        XCTAssertEqual(buffer, testData)
    }

    func testWriterBecomeWriter() throws {
        var body: Body = .writer { writerStream in
            try writerStream.write(self.testData, deadline: 1.second.fromNow())
            try writerStream.flush(deadline: 1.second.fromNow())
        }
        let writer = try body.becomeWriter(deadline: 1.second.fromNow())
        let writerStream = BufferStream()
        try writer(writerStream)
        XCTAssertFalse(body.isBuffer)
        XCTAssertFalse(body.isReader)
        XCTAssertTrue(body.isWriter)
        XCTAssertFalse(writerStream.closed)
        let buffer = try writerStream.read(upTo: testData.count, deadline: 1.second.fromNow())
        XCTAssertFalse(writerStream.closed)
        XCTAssertEqual(buffer.count, testData.count)
        XCTAssertEqual(buffer, testData)
    }

    func testBodyEquality() {
        let buffer = Body.buffer(testData)

        let bufferStream = BufferStream(buffer: testData)
        let reader = Body.reader(bufferStream)

        let writer = Body.writer { stream in
            try stream.write(self.testData, deadline: 1.second.fromNow())
            try stream.flush(deadline: 1.second.fromNow())
        }

        XCTAssertEqual(buffer, buffer)
        XCTAssertNotEqual(buffer, reader)
        XCTAssertNotEqual(buffer, writer)
        XCTAssertNotEqual(reader, writer)
    }
}

extension BodyTests {
    public static var allTests: [(String, (BodyTests) -> () throws -> Void)] {
        return [
            ("testBufferBecomeBuffer", testBufferBecomeBuffer),
            ("testBodyEquality", testBodyEquality),
        ]
    }
}
