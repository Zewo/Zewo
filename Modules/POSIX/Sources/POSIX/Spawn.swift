#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public enum SpawnError : Error {
    case exitStatus(Int32, [String])
}

extension SpawnError : CustomStringConvertible {
    public var description: String {
        switch self {
        case .exitStatus(let code, let args):
            return "exit(\(code)): \(args)"
        }
    }
}

public func spawn(arguments: [String]) throws -> PID {
    let argv: [UnsafeMutablePointer<CChar>?] = arguments.map {
        $0.withCString(strdup)
    }

    defer {
        for case let a? in argv {
            free(a)
        }
    }

    var envs: [String: String] = [:]

    #if Xcode
        let keys = ["SWIFT_EXEC", "HOME", "PATH", "TOOLCHAINS", "DEVELOPER_DIR", "LLVM_PROFILE_FILE"]
    #else
        let keys = ["SWIFT_EXEC", "HOME", "PATH", "SDKROOT", "TOOLCHAINS", "DEVELOPER_DIR", "LLVM_PROFILE_FILE"]
    #endif

    for key in keys {
        if envs[key] == nil {
            envs[key] = environment[key]
        }
    }

    let env: [UnsafeMutablePointer<CChar>?] = envs.map {
        "\($0.0)=\($0.1)".withCString(strdup)
    }

    defer {
        for case let e? in env {
            free(e)
        }
    }

    var pid = pid_t()
    let rv = posix_spawnp(&pid, argv[0], nil, nil, argv + [nil], env + [nil])

    if rv != 0 {
        try ensureLastOperationSucceeded()
    }

    return pid
}
