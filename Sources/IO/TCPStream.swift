#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Venice
import Core
import CLibdill

public final class TCPStream : DuplexStream {
    internal typealias Handle = Int32
    
    private var handle: Handle
    public var ip: IP
    private var open: Bool

    internal init(handle: Handle, ip: IP, open: Bool) {
        self.handle = handle
        self.ip = ip
        self.open = open
    }
    
    public convenience init(ip: IP) {
        self.init(handle: -1, ip: ip, open: false)
    }

    deinit {
        if open {
            hclose(handle)
        }
    }

    public convenience init(host: String, port: Int, deadline: Deadline) throws {
        let ip = try IP(remote: host, port: port, deadline: deadline)
        self.init(ip: ip)
    }

    public func open(deadline: Deadline) throws {
        guard !open else {
            throw SystemError.socketIsAlreadyConnected
        }
 
        var address = ip.address
        let result = tcp_connect(&address, deadline.value)
        
        guard result != -1 else {
            switch errno {
            default:
                throw SystemError.lastOperationError
            }
        }

        self.handle = result
        self.open = true
    }

    public func read(
        _ buffer: UnsafeMutableRawBufferPointer,
        deadline: Deadline
    ) throws -> UnsafeRawBufferPointer {
        try assertOpen()
        let result = brecv(handle, buffer.baseAddress, buffer.count, deadline.value)
        
        guard result != -1 else {
            switch errno {
            default:
                throw SystemError.lastOperationError
            }
        }
        
        #if swift(>=3.2)
            return UnsafeRawBufferPointer(rebasing: buffer.prefix(upTo: result))
        #else
            return UnsafeRawBufferPointer(buffer.prefix(upTo: result))
        #endif
    }
    
    public func write(_ buffer: UnsafeRawBufferPointer, deadline: Deadline) throws {
        try assertOpen()
        let result = bsend(handle, buffer.baseAddress, buffer.count, deadline.value)
        
        guard result != -1 else {
            switch errno {
            default:
                throw SystemError.lastOperationError
            }
        }
    }
    
    public func close(deadline: Deadline) throws {
        try assertOpen()
        
        defer {
            open = false
        }
        
        let result = hclose(handle)
        
        guard result != -1 else {
            switch errno {
            default:
                throw SystemError.lastOperationError
            }
        }
    }
    
    private func assertOpen() throws {
        guard open else {
            throw SystemError.socketIsNotConnected
        }
    }
}
