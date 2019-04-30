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
    func log(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String],
        level: LoggingLevel,
        tag: String,
        function: String
    )
}

public extension Logger {
    func log(_ message: @autoclosure () -> String, level: LoggingLevel, tag: String, function: String = #function) {
        log(message(), meta: [:], level: level, tag: tag, function: function)
    }

    func verbose(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        tag: String,
        function: String = #function
    ) {
        log(message(), meta: meta(), level: .verbose, tag: tag, function: function)
    }

    func debug(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        tag: String,
        function: String = #function
    ) {
        log(message(), meta: meta(), level: .debug, tag: tag, function: function)
    }

    func info(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        tag: String,
        function: String = #function
    ) {
        log(message(), meta: meta(), level: .info, tag: tag, function: function)
    }

    func warning(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        tag: String,
        function: String = #function
    ) {
        log(message(), meta: meta(), level: .warning, tag: tag, function: function)
    }

    func error(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        tag: String,
        function: String = #function
    ) {
        log(message(), meta: meta(), level: .error, tag: tag, function: function)
    }
}
