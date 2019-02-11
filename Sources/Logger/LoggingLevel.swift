//
// LoggingLevel
// Legacy
//
// Created by Alexander Babaev.
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

/// Logging levels for configuration. Should be the same as LoggingLevel, usually with "disabled" addition.
public enum LoggingConfigurationLevel {
    case verbose
    case debug
    case info
    case warning
    case error

    case disabled
}

public enum LoggingLevel {
    case verbose
    case debug
    case info
    case warning
    case error

    /// Defines order of logging levels for comparison with configuration level.
    private static let loggingLevels: [LoggingLevel] = [
        .verbose,
        .debug,
        .info,
        .warning,
        .error,
    ]

    /// Defines order of configuration levels for comparison with logging level.
    private static let loggingConfigurationLevels: [LoggingConfigurationLevel] = [
        .verbose,
        .debug,
        .info,
        .warning,
        .error,

        .disabled,
    ]

    public func isEnabled(for configurationLevel: LoggingConfigurationLevel) -> Bool {
        let loggingLevel = LoggingLevel.loggingLevels.firstIndex(of: self) ?? Int.max
        let configLevel = LoggingLevel.loggingConfigurationLevels.firstIndex(of: configurationLevel) ?? Int.max
        return loggingLevel >= configLevel
    }
}
