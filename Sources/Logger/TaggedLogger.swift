//
// TaggedLogger
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

/**
    Tagged logger, that contains tag inside and has simpler interface because of that.
    Can be used like this:

        protocol TaggedLoggerDependency {
            var logger: TaggedLogger! { get set }
        }

    And then in the configurator:

        container.register { (object: inout TaggedLoggerDependency) in
            let taggedLogger = SimpleTaggedLogger(logger: logger, for: object)
            object.logger = taggedLogger
        }
 */

public protocol TaggedLogger: Logger {
    var tag: String { get }

    func log(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String],
        level: LoggingLevel,
        file: StaticString,
        function: StaticString,
        line: UInt
    )
}

public extension TaggedLogger {
    func log(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        level: LoggingLevel,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(message(), meta: meta(), level: level, tag: tag, file: file, function: function, line: line)
    }

    func verbose(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(message(), meta: meta(), level: .verbose, file: file, function: function, line: line)
    }

    func debug(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(message(), meta: meta(), level: .debug, file: file, function: function, line: line)
    }

    func info(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(message(), meta: meta(), level: .info, file: file, function: function, line: line)
    }

    func warning(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(message(), meta: meta(), level: .warning, file: file, function: function, line: line)
    }

    func error(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String] = [:],
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        log(message(), meta: meta(), level: .error, file: file, function: function, line: line)
    }
}
