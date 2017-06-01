//
// NSLogLogger
// EE Utilities
//
// Created by Alexander Babaev.
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

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

    public func log(_ message: @autoclosure () -> String, level: LoggingLevel, for tag: String, function: String) {
        NSLog("%@ %@%@ %@", name(for: level), tag, function.isEmpty ? "" : ".\(function)", message())
    }
}
