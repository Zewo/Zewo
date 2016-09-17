#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public typealias PID = pid_t
