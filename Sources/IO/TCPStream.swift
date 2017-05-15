#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Core
import Venice
import POSIX

import CLibdill

public final class TCPStream : Handle, DuplexStream {
    public var ip: IP

    init(handle: HandleDescriptor, ip: IP) {
        self.ip = ip
        super.init(handle: handle)
    }
    
    public init(ip: IP) {
        self.ip = ip
        super.init(handle: -1)
    }

    public convenience init(host: String, port: Int, deadline: Deadline) throws {
        let ip = try IP(remote: host, port: port, deadline: deadline)
        self.init(ip: ip)
    }

    public func open(deadline: Deadline) throws {
        var address = ip.address
        let result = tcp_connect(&address, deadline.value)
        
        guard result != -1 else {
            switch errno {
            default:
                throw SystemError.lastOperationError
            }
        }

        self.handle = result
    }

    public func read(
        _ buffer: UnsafeMutableRawBufferPointer,
        deadline: Deadline
    ) throws -> UnsafeRawBufferPointer {
        let result = brecv(handle, buffer.baseAddress, buffer.count, deadline.value)
        
        guard result != -1 else {
            switch errno {
            default:
                throw SystemError.lastOperationError
            }
        }
        
        return UnsafeRawBufferPointer(buffer).prefix(result)
    }
    
    public func write(_ buffer: UnsafeRawBufferPointer, deadline: Deadline) throws {
        let result = bsend(handle, buffer.baseAddress, buffer.count, deadline.value)
        
        guard result != -1 else {
            switch errno {
            default:
                throw SystemError.lastOperationError
            }
        }
    }
    
    public override func done(deadline: Deadline) throws {
        let result = tcp_close(handle, deadline.value)
        
        guard result != -1 else {
            switch errno {
            default:
                throw SystemError.lastOperationError
            }
        }
    }
}
