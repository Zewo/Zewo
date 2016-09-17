#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public func system(_ arguments: [String]) throws {
    fflush(stdout)
    guard !arguments.isEmpty else {
        throw SystemError.invalidArgument
    }

    let pid = try spawn(arguments: arguments)
    let exitStatus = try wait(pid: pid)

    guard exitStatus == 0 else {
        throw SpawnError.exitStatus(exitStatus, arguments)
    }
}
