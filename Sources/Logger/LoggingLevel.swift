//
// LoggingLevel
// Legacy
//
// Created by Alexander Babaev.
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

/// Logging levels for configuration. Should be the same as LoggingLevel, usually with "disabled" addition.
public enum LoggingConfigurationLevel: Int {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case disabled = 5
}

public enum LoggingLevel: Int {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case critical = 5

    public func isEnabled(for configurationLevel: LoggingConfigurationLevel) -> Bool {
        rawValue >= configurationLevel.rawValue
    }

    public var emoji: String {
        switch self {
            case .verbose:
                return "💬️"
            case .debug:
                return "🔬"
            case .info:
                return "🌵"
            case .warning:
                return "🖖"
            case .error:
                return "🌶"
            case .critical:
                return "🚨"
        }
    }
}
