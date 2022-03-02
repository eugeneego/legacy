//
// Logger
// Legacy
//
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
        file: StaticString,
        function: StaticString,
        line: UInt
    )
}

public extension Logger {
    func log(
        _ message: @autoclosure () -> String,
        level: LoggingLevel,
        tag: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(message(), meta: [:], level: level, tag: tag, file: file, function: function, line: line)
    }

    func verbose(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        tag: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(message(), meta: meta(), level: .verbose, tag: tag, file: file, function: function, line: line)
    }

    func debug(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        tag: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(message(), meta: meta(), level: .debug, tag: tag, file: file, function: function, line: line)
    }

    func info(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        tag: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(message(), meta: meta(), level: .info, tag: tag, file: file, function: function, line: line)
    }

    func warning(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        tag: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(message(), meta: meta(), level: .warning, tag: tag, file: file, function: function, line: line)
    }

    func error(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        tag: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(message(), meta: meta(), level: .error, tag: tag, file: file, function: function, line: line)
    }
}
