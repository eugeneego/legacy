//
// LoggingLevel
// EE Utilities
//
// Created by Alexander Babaev.
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

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

    private static let loggingLevels: [LoggingLevel] = [
        .verbose,
        .debug,
        .info,
        .warning,
        .error,
    ]

    private static let loggingConfigurationLevels: [LoggingConfigurationLevel] = [
        .verbose,
        .debug,
        .info,
        .warning,
        .error,

        .disabled,
    ]

    public func isEnabled(for configurationLevel: LoggingConfigurationLevel) -> Bool {
        let loggingLevel = LoggingLevel.loggingLevels.index(of: self) ?? Int.max
        let configLevel = LoggingLevel.loggingConfigurationLevels.index(of: configurationLevel) ?? Int.max
        return loggingLevel >= configLevel
    }
}
