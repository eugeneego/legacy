//
// NSLogLogger
// Legacy
//
// Created by Alexander Babaev.
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

/// Simple NSLog logger. Please be warned that NSLog is not able to show long messages.
public class NSLogLogger: Logger {
    public init() {
    }

    private func name(for level: LoggingLevel) -> String {
        switch level {
            case .verbose:
                return "💬️"
            case .debug:
                return "🔬"
            case .info:
                return "🌵"
            case .warning:
                return "🖖"
            case .error:
                return "⛑"
        }
    }

    public func log(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String],
        level: LoggingLevel,
        tag: String,
        function: String
    ) {
        NSLog("%@ %@%@ %@", name(for: level), tag, function.isEmpty ? "" : ".\(function)", message())
    }
}
