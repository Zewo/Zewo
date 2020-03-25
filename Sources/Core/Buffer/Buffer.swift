import Foundation

public protocol BufferInitializable {
    init(_ buffer: UnsafeRawBufferPointer)
}

extension BufferInitializable {
    public init(_ buffer: UnsafeMutableRawBufferPointer) {
        self.init(UnsafeRawBufferPointer(buffer))
    }
}

extension Data : BufferInitializable {}

extension String : BufferInitializable {
    public init(_ buffer: UnsafeRawBufferPointer) {
        let bytes = [UInt8](buffer) + [0]
        self.init(cString: bytes)
    }
}

public protocol BufferRepresentable {
    /// Number of bytes in the buffer representation.
    var bufferSize: Int { get }
    
    /// Invokes the given closure on the contents represented as a buffer.
    ///
    /// The `withUnsafeBytes(_ body:)` method ensures that the buffer's lifetime extends
    /// through the execution of `body`. The buffer argument to `body` is only
    /// valid for the lifetime of the closure. Do not escape it from the closure
    /// for later use.
    ///
    /// - Parameter body: A closure that takes a buffer as its sole argument.
    ///   If the closure has a return value, it is used as the return value of
    ///   the `withUnsafeBytes(_ body:)` method.
    ///   The buffer argument is valid only for the duration of the closure's
    ///   execution.
    /// - Parameter buffer: A buffer representing the contents of the underlying type.
    /// - Returns: The return value of the `body` closure, if any.
    /// - Throws: Errors thrown from the `body` closure, if any.
    func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R
}

extension UnsafeRawBufferPointer : BufferRepresentable {
    public var bufferSize: Int {
        return count
    }
}

extension String : BufferRepresentable {
    public var bufferSize: Int {
        return utf8.count
    }
    
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try withCString { unsafePointer in
            let unsafeRawBufferPointer = UnsafeRawBufferPointer(
                start: UnsafeRawPointer(unsafePointer),
                count: utf8.count
            )
            
            return try body(unsafeRawBufferPointer)
        }
    }
}

extension Data : BufferRepresentable {
    public var bufferSize: Int {
        return count
    }
}

extension Collection where Iterator.Element == UInt8 {
    // TODO: Improve this
    public var hexString: String {
        var string = ""
        
        for byte in self {
            if byte < 0x10 {
                string += "0"
            }
            
            string += String(byte, radix: 16, uppercase: false)
        }
        
        return string
    }
}
