//
// TaggedLogger
// Legacy
//
// Created by Alex Babaev on 03 May 2018.
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
    func log(_ message: @autoclosure () -> String, level: LoggingLevel, function: String)
}

public extension TaggedLogger {
    func log(_ message: @autoclosure () -> String, level: LoggingLevel, function: String) {
        log(message(), level: level, tag: tag, function: function)
    }

    func verbose(_ message: @autoclosure () -> String, function: String = #function) {
        log(message(), level: .verbose, function: function)
    }

    func debug(_ message: @autoclosure () -> String, function: String = #function) {
        log(message(), level: .debug, function: function)
    }

    func info(_ message: @autoclosure () -> String, function: String = #function) {
        log(message(), level: .info, function: function)
    }

    func warning(_ message: @autoclosure () -> String, function: String = #function) {
        log(message(), level: .warning, function: function)
    }

    func error(_ message: @autoclosure () -> String, function: String = #function) {
        log(message(), level: .error, function: function)
    }
}
