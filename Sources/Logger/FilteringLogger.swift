//
// FilteringLogger
// Legacy
//
// Created by Alexander Babaev.
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public class FilteringLogger: Logger {
    private let logger: Logger

    private let tagLoggingLevels: [String: LoggingConfigurationLevel]
    private let defaultLoggingLevel: LoggingConfigurationLevel

    public init(logger: Logger, tagLoggingLevels: [String: LoggingConfigurationLevel], defaultLoggingLevel: LoggingConfigurationLevel) {
        self.logger = logger
        self.tagLoggingLevels = tagLoggingLevels
        self.defaultLoggingLevel = defaultLoggingLevel
    }

    public func log(_ message: @autoclosure () -> String, level: LoggingLevel, for tag: String, function: String) {
        let configLevel = tagLoggingLevels[tag] ?? defaultLoggingLevel
        guard level.isEnabled(for: configLevel) else { return }

        logger.log(message, level: level, for: tag, function: function)
    }
}
