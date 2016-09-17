#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public func wait(pid: PID) throws -> Int32 {
    while true {
        var exitStatus: Int32 = 0
        let rv = waitpid(pid, &exitStatus, 0)

        if rv != -1 {
            if exitStatus & 0x7f == 0 {
                return (exitStatus >> 8) & 0xff
            } else {
                try ensureLastOperationSucceeded()
            }
        } else if errno == EINTR {
            continue
        } else {
            try ensureLastOperationSucceeded()
        }
    }
}
