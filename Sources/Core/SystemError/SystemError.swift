#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

/// POSIX error representation.
///
/// ## Example:
///
/// ```swift
/// func listen(socket: Int32, backlog: Int32) throws {
///     let result = listen(socket, backlog)
///
///     guard result != -1 else {
///        throw SystemError.lastOperationError
///     }
/// }
///  
/// do {
///     try listen(socket: socket)
/// } catch SystemError.addressAlreadyInUse {
///     print("Another socket is already listening on the same port.")
/// }
/// ```
public enum SystemError : Error {
    /// Error from the last executed operation, if any.
    /// The error is created from the value present in `errno`.
    ///
    /// - Warning:
    /// `lastOperationError` is significant only when the return
    /// value of the last operation indicated an error (i.e., -1 from
    /// most system calls; -1 or `nil` from most library functions).
    public static var lastOperationError: SystemError {
        return SystemError(errorNumber: errno)
    }
    
    /// No error.
    case success
    /// Operation not permitted. Equivalent of `EPERM`.
    case operationNotPermitted
    /// No such file or directory. Equivalent of `ENOENT`.
    case noSuchFileOrDirectory
    /// No such process. Equivalent of `ESRCH`.
    case noSuchProcess
    /// Interrupted system call. Equivalent of `EINTR`.
    case interruptedSystemCall
    /// Input-output error. Equivalent of `EIO`.
    case inputOutputError
    /// Device not configured. Equivalent of `ENXIO`.
    case deviceNotConfigured
    /// Argument list too long. Equivalent of `E2BIG`.
    case argumentListTooLong
    /// Executable format error. Equivalent of `ENOEXEC`.
    case executableFormatError
    /// Bad file descriptor. Equivalent of `EBADF`.
    case badFileDescriptor
    /// No child process. Equivalent of `ECHILD`.
    case noChildProcesses
    /// Resource deadlock avoided. Equivalent of `EDEADLK`.
    case resourceDeadlockAvoided
    /// Cannot allocate memory. Equivalent of `ENOMEM`.
    case cannotAllocateMemory
    /// Permission denied. Equivalent of `EACCES`.
    case permissionDenied
    /// Bad address. Equivalent of `EFAULT`.
    case badAddress
    /// Block device required. Equivalent of `ENOTBLK`.
    case blockDeviceRequired
    /// Device or resource busy. Equivalent of `EBUSY`.
    case deviceOrResourceBusy
    /// File exists. Equivalent of `EEXIST`.
    case fileExists
    /// Cross device link. Equivalent of `EXDEV`.
    case crossDeviceLink
    /// Operation not supported by device. Equivalent of `ENODEV`.
    case operationNotSupportedByDevice
    /// Not a directory. Equivalent of `ENOTDIR`.
    case notADirectory
    /// Is a directory. Equivalent of `EISDIR`.
    case isADirectory
    /// Invalid argument. Equivalent of `EINVAL`.
    case invalidArgument
    /// Too many open files in system. Equivalent of `ENFILE`.
    case tooManyOpenFilesInSystem
    /// Too many open files. Equivalent of `EMFILE`.
    case tooManyOpenFiles
    /// Inappropriate Input-output control for device. Equivalent of `ENOTTY`.
    case inappropriateInputOutputControlForDevice
    /// Text file busy. Equivalent of `ETXTBSY`.
    case textFileBusy
    /// File too large. Equivalent of `EFBIG`.
    case fileTooLarge
    /// No space left on device. Equivalent of `ENOSPC`.
    case noSpaceLeftOnDevice
    /// Illegal seek. Equivalent of `ESPIPE`.
    case illegalSeek
    /// Read-only file system. Equivalent of `EROFS`.
    case readOnlyFileSystem
    /// Too many links. Equivalent of `EMLINK`.
    case tooManyLinks
    /// Broken pipe. Equivalent of `EPIPE`.
    case brokenPipe
    /// Numerical argument out of domain. Equivalent of `EDOM`.
    case numericalArgumentOutOfDomain
    /// Result too large. Equivalent of `ERANGE`.
    case resultTooLarge
    /// Resource temporarily unavailable. Equivalent of `EAGAIN`.
    case resourceTemporarilyUnavailable
    /// Operation would block. Equivalent of `EWOULDBLOCK`.
    case operationWouldBlock
    /// Operation now in progress. Equivalent of `EINPROGRESS`.
    case operationNowInProgress
    /// Operation already in progress. Equivalent of `EALREADY`.
    case operationAlreadyInProgress
    /// Socket operation on non socket. Equivalent of `ENOTSOCK`.
    case socketOperationOnNonSocket
    /// Destination address required. Equivalent of `EDESTADDRREQ`.
    case destinationAddressRequired
    /// Message too long. Equivalent of `EMSGSIZE`.
    case messageTooLong
    /// Protocol of wrong type for socket. Equivalent of `EPROTOTYPE`.
    case protocolWrongTypeForSocket
    /// Protocol not available. Equivalent of `ENOPROTOOPT`.
    case protocolNotAvailable
    /// Protocol not supported. Equivalent of `EPROTONOSUPPORT`.
    case protocolNotSupported
    /// Socket type not supported. Equivalent of `ESOCKTNOSUPPORT`.
    case socketTypeNotSupported
    /// Operation not supported. Equivalent of `ENOTSUP`.
    case operationNotSupported
    /// Protocol family not supported. Equivalent of `EPFNOSUPPORT`.
    case protocolFamilyNotSupported
    /// Address family not supported by protocol family. Equivalent of `EAFNOSUPPORT`.
    case addressFamilyNotSupportedByProtocolFamily
    /// Address already in use. Equivalent of `EADDRINUSE`.
    case addressAlreadyInUse
    /// Cannot assign requested address. Equivalent of `EADDRNOTAVAIL`.
    case cannotAssignRequestedAddress
    /// Network is down. Equivalent of `ENETDOWN`.
    case networkIsDown
    /// Network is unreachable. Equivalent of `ENETUNREACH`.
    case networkIsUnreachable
    /// Network dropped connection on reset. Equivalent of `ENETRESET`.
    case networkDroppedConnectionOnReset
    /// Software caused connection abort. Equivalent of `ECONNABORTED`.
    case softwareCausedConnectionAbort
    /// Connection reset by peer. Equivalent of `ECONNRESET`.
    case connectionResetByPeer
    /// No buffer space available. Equivalent of `ENOBUFS`.
    case noBufferSpaceAvailable
    /// Socket is already connected. Equivalent of `EISCONN`.
    case socketIsAlreadyConnected
    /// Socket is not connected. Equivalent of `ENOTCONN`.
    case socketIsNotConnected
    /// Cannot send after socket shutdown. Equivalent of `ESHUTDOWN`.
    case cannotSendAfterSocketShutdown
    /// Too many references. Equivalent of `ETOOMANYREFS`.
    case tooManyReferences
    /// Operation timed out. Equivalent of `ETIMEDOUT`.
    case operationTimedOut
    /// Connection refused. Equivalent of `ECONNREFUSED`.
    case connectionRefused
    /// Too many levels of symbolic links. Equivalent of `ELOOP`.
    case tooManyLevelsOfSymbolicLinks
    /// File name too long. Equivalent of `ENAMETOOLONG`.
    case fileNameTooLong
    /// Host is down. Equivalent of `EHOSTDOWN`.
    case hostIsDown
    /// No route to host. Equivalent of `EHOSTUNREACH`.
    case noRouteToHost
    /// Directory not empty. Equivalent of `ENOTEMPTY`.
    case directoryNotEmpty
    /// Too many users. Equivalent of `EUSERS`.
    case tooManyUsers
    /// Disk quota exceeded. Equivalent of `EDQUOT`.
    case diskQuotaExceeded
    /// Stale file handle. Equivalent of `ESTALE`.
    case staleFileHandle
    /// Object is remote. Equivalent of `EREMOTE`.
    case objectIsRemote
    /// No locks available. Equivalent of `ENOLCK`.
    case noLocksAvailable
    /// Function not implemented. Equivalent of `ENOSYS`.
    case functionNotImplemented
    /// Value too large for defined data type. Equivalent of `EOVERFLOW`.
    case valueTooLargeForDefinedDataType
    /// Operation canceled. Equivalent of `ECANCELED`.
    case operationCanceled
    /// Identifier removed. Equivalent of `EIDRM`.
    case identifierRemoved
    /// No message of desired type. Equivalent of `ENOMSG`.
    case noMessageOfDesiredType
    /// Illegal byte sequence. Equivalent of `EILSEQ`.
    case illegalByteSequence
    /// Bad message. Equivalent of `EBADMSG`.
    case badMessage
    /// Multihop attempted. Equivalent of `EMULTIHOP`.
    case multihopAttempted
    /// No data available. Equivalent of `ENODATA`.
    case noDataAvailable
    /// Link has been severed. Equivalent of `ENOLINK`.
    case linkHasBeenSevered
    /// Out of stream resources. Equivalent of `ENOSR`.
    case outOfStreamsResources
    /// Device not a stream. Equivalent of `ENOSTR`.
    case deviceNotAStream
    /// Protocol error. Equivalent of `EPROTO`.
    case protocolError
    /// Timer expired. Equivalent of `ETIME`.
    case timerExpired
    /// State not recoverable. Equivalent of `ENOTRECOVERABLE`.
    case stateNotRecoverable
    /// Previous owner died. Equivalent of `EOWNERDEAD`.
    case previousOwnerDied
    /// Other error not listed above. Equivalent of `errorNumber`.
    case other(errorNumber: Int32)
    
    /// Initializes `SystemError` with the given POSIX error number.
    ///
    /// - Parameter errorNumber: POSIX error number representing the error.
    public init(errorNumber: Int32) {
        switch errorNumber {
        case 0:               self = .success
        case EPERM:           self = .operationNotPermitted
        case ENOENT:          self = .noSuchFileOrDirectory
        case ESRCH:           self = .noSuchProcess
        case EINTR:           self = .interruptedSystemCall
        case EIO:             self = .inputOutputError
        case ENXIO:           self = .deviceNotConfigured
        case E2BIG:           self = .argumentListTooLong
        case ENOEXEC:         self = .executableFormatError
        case EBADF:           self = .badFileDescriptor
        case ECHILD:          self = .noChildProcesses
        case EDEADLK:         self = .resourceDeadlockAvoided
        case ENOMEM:          self = .cannotAllocateMemory
        case EACCES:          self = .permissionDenied
        case EFAULT:          self = .badAddress
        case ENOTBLK:         self = .blockDeviceRequired
        case EBUSY:           self = .deviceOrResourceBusy
        case EEXIST:          self = .fileExists
        case EXDEV:           self = .crossDeviceLink
        case ENODEV:          self = .operationNotSupportedByDevice
        case ENOTDIR:         self = .notADirectory
        case EISDIR:          self = .isADirectory
        case EINVAL:          self = .invalidArgument
        case ENFILE:          self = .tooManyOpenFilesInSystem
        case EMFILE:          self = .tooManyOpenFiles
        case ENOTTY:          self = .inappropriateInputOutputControlForDevice
        case ETXTBSY:         self = .textFileBusy
        case EFBIG:           self = .fileTooLarge
        case ENOSPC:          self = .noSpaceLeftOnDevice
        case ESPIPE:          self = .illegalSeek
        case EROFS:           self = .readOnlyFileSystem
        case EMLINK:          self = .tooManyLinks
        case EPIPE:           self = .brokenPipe
        case EDOM:            self = .numericalArgumentOutOfDomain
        case ERANGE:          self = .resultTooLarge
        case EAGAIN:          self = .resourceTemporarilyUnavailable
        case EWOULDBLOCK:     self = .operationWouldBlock
        case EINPROGRESS:     self = .operationNowInProgress
        case EALREADY:        self = .operationAlreadyInProgress
        case ENOTSOCK:        self = .socketOperationOnNonSocket
        case EDESTADDRREQ:    self = .destinationAddressRequired
        case EMSGSIZE:        self = .messageTooLong
        case EPROTOTYPE:      self = .protocolWrongTypeForSocket
        case ENOPROTOOPT:     self = .protocolNotAvailable
        case EPROTONOSUPPORT: self = .protocolNotSupported
        case ESOCKTNOSUPPORT: self = .socketTypeNotSupported
        case ENOTSUP:         self = .operationNotSupported
        case EPFNOSUPPORT:    self = .protocolFamilyNotSupported
        case EAFNOSUPPORT:    self = .addressFamilyNotSupportedByProtocolFamily
        case EADDRINUSE:      self = .addressAlreadyInUse
        case EADDRNOTAVAIL:   self = .cannotAssignRequestedAddress
        case ENETDOWN:        self = .networkIsDown
        case ENETUNREACH:     self = .networkIsUnreachable
        case ENETRESET:       self = .networkDroppedConnectionOnReset
        case ECONNABORTED:    self = .softwareCausedConnectionAbort
        case ECONNRESET:      self = .connectionResetByPeer
        case ENOBUFS:         self = .noBufferSpaceAvailable
        case EISCONN:         self = .socketIsAlreadyConnected
        case ENOTCONN:        self = .socketIsNotConnected
        case ESHUTDOWN:       self = .cannotSendAfterSocketShutdown
        case ETOOMANYREFS:    self = .tooManyReferences
        case ETIMEDOUT:       self = .operationTimedOut
        case ECONNREFUSED:    self = .connectionRefused
        case ELOOP:           self = .tooManyLevelsOfSymbolicLinks
        case ENAMETOOLONG:    self = .fileNameTooLong
        case EHOSTDOWN:       self = .hostIsDown
        case EHOSTUNREACH:    self = .noRouteToHost
        case ENOTEMPTY:       self = .directoryNotEmpty
        case EUSERS:          self = .tooManyUsers
        case EDQUOT:          self = .diskQuotaExceeded
        case ESTALE:          self = .staleFileHandle
        case EREMOTE:         self = .objectIsRemote
        case ENOLCK:          self = .noLocksAvailable
        case ENOSYS:          self = .functionNotImplemented
        case EOVERFLOW:       self = .valueTooLargeForDefinedDataType
        case ECANCELED:       self = .operationCanceled
        case EIDRM:           self = .identifierRemoved
        case ENOMSG:          self = .noMessageOfDesiredType
        case EILSEQ:          self = .illegalByteSequence
        case EBADMSG:         self = .badMessage
        case EMULTIHOP:       self = .multihopAttempted
        case ENODATA:         self = .noDataAvailable
        case ENOLINK:         self = .linkHasBeenSevered
        case ENOSR:           self = .outOfStreamsResources
        case ENOSTR:          self = .deviceNotAStream
        case EPROTO:          self = .protocolError
        case ETIME:           self = .timerExpired
        case ENOTRECOVERABLE: self = .stateNotRecoverable
        case EOWNERDEAD:      self = .previousOwnerDied
        default:              self = .other(errorNumber: errorNumber)
        }
    }

    /// POSIX error number representing the error.
    public var errorNumber: Int32 {
        switch self {
        case .success:                                   return 0
        case .operationNotPermitted:                     return EPERM
        case .noSuchFileOrDirectory:                     return ENOENT
        case .noSuchProcess:                             return ESRCH
        case .interruptedSystemCall:                     return EINTR
        case .inputOutputError:                          return EIO
        case .deviceNotConfigured:                       return ENXIO
        case .argumentListTooLong:                       return E2BIG
        case .executableFormatError:                     return ENOEXEC
        case .badFileDescriptor:                         return EBADF
        case .noChildProcesses:                          return ECHILD
        case .resourceDeadlockAvoided:                   return EDEADLK
        case .cannotAllocateMemory:                      return ENOMEM
        case .permissionDenied:                          return EACCES
        case .badAddress:                                return EFAULT
        case .blockDeviceRequired:                       return ENOTBLK
        case .deviceOrResourceBusy:                      return EBUSY
        case .fileExists:                                return EEXIST
        case .crossDeviceLink:                           return EXDEV
        case .operationNotSupportedByDevice:             return ENODEV
        case .notADirectory:                             return ENOTDIR
        case .isADirectory:                              return EISDIR
        case .invalidArgument:                           return EINVAL
        case .tooManyOpenFilesInSystem:                  return ENFILE
        case .tooManyOpenFiles:                          return EMFILE
        case .inappropriateInputOutputControlForDevice:  return ENOTTY
        case .textFileBusy:                              return ETXTBSY
        case .fileTooLarge:                              return EFBIG
        case .noSpaceLeftOnDevice:                       return ENOSPC
        case .illegalSeek:                               return ESPIPE
        case .readOnlyFileSystem:                        return EROFS
        case .tooManyLinks:                              return EMLINK
        case .brokenPipe:                                return EPIPE
        case .numericalArgumentOutOfDomain:              return EDOM
        case .resultTooLarge:                            return ERANGE
        case .resourceTemporarilyUnavailable:            return EAGAIN
        case .operationWouldBlock:                       return EWOULDBLOCK
        case .operationNowInProgress:                    return EINPROGRESS
        case .operationAlreadyInProgress:                return EALREADY
        case .socketOperationOnNonSocket:                return ENOTSOCK
        case .destinationAddressRequired:                return EDESTADDRREQ
        case .messageTooLong:                            return EMSGSIZE
        case .protocolWrongTypeForSocket:                return EPROTOTYPE
        case .protocolNotAvailable:                      return ENOPROTOOPT
        case .protocolNotSupported:                      return EPROTONOSUPPORT
        case .socketTypeNotSupported:                    return ESOCKTNOSUPPORT
        case .operationNotSupported:                     return ENOTSUP
        case .protocolFamilyNotSupported:                return EPFNOSUPPORT
        case .addressFamilyNotSupportedByProtocolFamily: return EAFNOSUPPORT
        case .addressAlreadyInUse:                       return EADDRINUSE
        case .cannotAssignRequestedAddress:              return EADDRNOTAVAIL
        case .networkIsDown:                             return ENETDOWN
        case .networkIsUnreachable:                      return ENETUNREACH
        case .networkDroppedConnectionOnReset:           return ENETRESET
        case .softwareCausedConnectionAbort:             return ECONNABORTED
        case .connectionResetByPeer:                     return ECONNRESET
        case .noBufferSpaceAvailable:                    return ENOBUFS
        case .socketIsAlreadyConnected:                  return EISCONN
        case .socketIsNotConnected:                      return ENOTCONN
        case .cannotSendAfterSocketShutdown:             return ESHUTDOWN
        case .tooManyReferences:                         return ETOOMANYREFS
        case .operationTimedOut:                         return ETIMEDOUT
        case .connectionRefused:                         return ECONNREFUSED
        case .tooManyLevelsOfSymbolicLinks:              return ELOOP
        case .fileNameTooLong:                           return ENAMETOOLONG
        case .hostIsDown:                                return EHOSTDOWN
        case .noRouteToHost:                             return EHOSTUNREACH
        case .directoryNotEmpty:                         return ENOTEMPTY
        case .tooManyUsers:                              return EUSERS
        case .diskQuotaExceeded:                         return EDQUOT
        case .staleFileHandle:                           return ESTALE
        case .objectIsRemote:                            return EREMOTE
        case .noLocksAvailable:                          return ENOLCK
        case .functionNotImplemented:                    return ENOSYS
        case .valueTooLargeForDefinedDataType:           return EOVERFLOW
        case .operationCanceled:                         return ECANCELED
        case .identifierRemoved:                         return EIDRM
        case .noMessageOfDesiredType:                    return ENOMSG
        case .illegalByteSequence:                       return EILSEQ
        case .badMessage:                                return EBADMSG
        case .multihopAttempted:                         return EMULTIHOP
        case .noDataAvailable:                           return ENODATA
        case .linkHasBeenSevered:                        return ENOLINK
        case .outOfStreamsResources:                     return ENOSR
        case .deviceNotAStream:                          return ENOSTR
        case .protocolError:                             return EPROTO
        case .timerExpired:                              return ETIME
        case .stateNotRecoverable:                       return ENOTRECOVERABLE
        case .previousOwnerDied:                         return EOWNERDEAD
        case .other(let errorNumber):                    return errorNumber
        }
    }
}

extension SystemError : Equatable {
    /// :nodoc:
    public static func == (lhs: SystemError, rhs: SystemError) -> Bool {
        return lhs.errorNumber == rhs.errorNumber
    }
}

extension SystemError : CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        return String(cString: strerror(errorNumber))
    }
}
