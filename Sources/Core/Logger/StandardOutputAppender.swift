public struct StandardOutputAppender : LogAppender {
    public let levels: Logger.Level

    public init(levels: Logger.Level = .all) {
        self.levels = levels
    }

    public func append(event: Logger.Event) {
        var logMessage = ""

        let level = event.level.description
        
        logMessage += level == "" ? "" : "[" + level + "]"
        logMessage += "[" + event.timestamp.description + "]"
        logMessage += "[" + event.locationInfo.description + "]"

        if let message = event.message {
            logMessage += ":" + String(describing: message)
        }

        if let error = event.error {
            logMessage += ":" + String(describing: error)
        }

        print(logMessage)
    }
}
