//
// Logger
// Legacy
//
// Created by Alexander Babaev.
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

/// Simple extendable logger. Please see TaggedLogger for more information.
public protocol Logger {
    func log(_ message: @autoclosure () -> String, level: LoggingLevel, tag: String, function: String)
}

public extension Logger {
    func verbose(_ message: @autoclosure () -> String, tag: String, function: String = #function) {
        log(message(), level: .verbose, tag: tag, function: function)
    }

    func debug(_ message: @autoclosure () -> String, tag: String, function: String = #function) {
        log(message(), level: .debug, tag: tag, function: function)
    }

    func info(_ message: @autoclosure () -> String, tag: String, function: String = #function) {
        log(message(), level: .info, tag: tag, function: function)
    }

    func warning(_ message: @autoclosure () -> String, tag: String, function: String = #function) {
        log(message(), level: .warning, tag: tag, function: function)
    }

    func error(_ message: @autoclosure () -> String, tag: String, function: String = #function) {
        log(message(), level: .error, tag: tag, function: function)
    }
}
