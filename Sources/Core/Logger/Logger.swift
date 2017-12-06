#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public protocol LogAppender {
    var levels: Logger.Level { get }
    func append(event: Logger.Event)
}

public struct Logger {
    public struct Level: OptionSet {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let trace   = Level(rawValue: 1 << 0)
        public static let debug   = Level(rawValue: 1 << 1)
        public static let info    = Level(rawValue: 1 << 2)
        public static let warning = Level(rawValue: 1 << 3)
        public static let error   = Level(rawValue: 1 << 4)
        public static let fatal   = Level(rawValue: 1 << 5)
        public static let all     = Level(rawValue: ~0)
    }

    public struct Event {
        public let locationInfo: LocationInfo
        public let timestamp: Int
        public let usec: Int
        public let level: Logger.Level
        public var message: Any?
        public var error: Error?
    }

    public struct LocationInfo {
        public let file: String
        public let line: Int
        public let column: Int
        public let function: String
        
        public init(
            file: String,
            line: Int,
            column: Int,
            function: String
        ) {
            self.file = file
            self.line = line
            self.column = column
            self.function = function
        }
    }

    public static var appenders: [LogAppender] = [StandardOutputAppender()]
    
    private static func log(level: Level, item: Any?, error: Error? = nil, locationInfo: LocationInfo) {
        let (ts, usec) = getTimestamp()
        let event = Event(
            locationInfo: locationInfo,
            timestamp: ts,
            usec: usec,
            level: level,
            message: item,
            error: error
        )
        
        for apender in appenders where apender.levels.contains(event.level) {
            apender.append(event: event)
        }
    }
    
    private static func log(
        level: Level,
        item: Any?,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        log(
            level: level,
            item: item,
            error: error,
            locationInfo: LocationInfo(
                file: file,
                line: line,
                column: column,
                function: function
            )
        )
    }

    public static func trace(
        _ item: Any?,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        log(
            level: .trace,
            item: item,
            error: error,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }
    
    public static func trace(
        _ item: Any?,
        error: Error? = nil,
        locationInfo: LocationInfo
    ) {
        log(
            level: .trace,
            item: item,
            error: error,
            locationInfo: locationInfo
        )
    }

    public static func debug(
        _ item: Any?,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        log(
            level: .debug,
            item: item,
            error: error,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }
    
    public static func debug(
        _ item: Any?,
        error: Error? = nil,
        locationInfo: LocationInfo
    ) {
        log(
            level: .debug,
            item: item,
            error: error,
            locationInfo: locationInfo
        )
    }

    public static func info(
        _ item: Any?,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        log(
            level: .info,
            item: item,
            error: error,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }
    
    public static func info(
        _ item: Any?,
        error: Error? = nil,
        locationInfo: LocationInfo
    ) {
        log(
            level: .info,
            item: item,
            error: error,
            locationInfo: locationInfo
        )
    }

    public static func warning(
        _ item: Any?,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        log(
            level: .warning,
            item: item,
            error: error,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }
    
    public static func warning(
        _ item: Any?,
        error: Error? = nil,
        locationInfo: LocationInfo
    ) {
        log(
            level: .warning,
            item: item,
            error: error,
            locationInfo: locationInfo
        )
    }

    public static func error(
        _ item: Any?,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        log(
            level: .error,
            item: item,
            error: error,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }
    
    public static func error(
        _ item: Any?,
        error: Error? = nil,
        locationInfo: LocationInfo
    ) {
        log(
            level: .error,
            item: item,
            error: error,
            locationInfo: locationInfo
        )
    }

    public static func fatal(
        _ item: Any?,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        log(
            level: .fatal,
            item: item,
            error: error,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }
    
    public static func fatal(
        _ item: Any?,
        error: Error? = nil,
        locationInfo: LocationInfo
    ) {
        log(
            level: .fatal,
            item: item,
            error: error,
            locationInfo: locationInfo
        )
    }

    private static func getTimestamp() -> (Int,Int) {
        var time: timeval = timeval(tv_sec: 0, tv_usec: 0)
        gettimeofday(&time, nil)
        return (time.tv_sec, Int(time.tv_usec))
    }
}

extension Logger.Level : CustomStringConvertible {
    public var description: String {
        if self == .trace {
            return "TRACE"
        }
        
        if self == .debug {
            return "DEBUG"
        }
        
        if self == .info {
            return "INFO"
        }
        
        if self == .warning {
            return "WARNING"
        }
        
        if self == .error {
            return "ERROR"
        }
        
        if self == .fatal {
            return "FATAL"
        }
        
        return ""
    }
}

extension Logger.LocationInfo : CustomStringConvertible {
    public var description: String {
        return "\(file):\(function):\(line):\(column)"
    }
}
