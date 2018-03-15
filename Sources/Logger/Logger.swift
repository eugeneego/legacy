//
// Logger
// Legacy
//
// Created by Alexander Babaev.
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public protocol Logger {
    func log(_ message: @autoclosure () -> String, level: LoggingLevel, for tag: String, function: String)
}

public extension Logger {
    public func verbose(_ message: @autoclosure () -> String, for tag: String, function: String = #function) {
        log(message, level: .verbose, for: tag, function: function)
    }

    public func debug(_ message: @autoclosure () -> String, for tag: String, function: String = #function) {
        log(message, level: .debug, for: tag, function: function)
    }

    public func info(_ message: @autoclosure () -> String, for tag: String, function: String = #function) {
        log(message, level: .info, for: tag, function: function)
    }

    public func warning(_ message: @autoclosure () -> String, for tag: String, function: String = #function) {
        log(message, level: .warning, for: tag, function: function)
    }

    public func error(_ message: @autoclosure () -> String, for tag: String, function: String = #function) {
        log(message, level: .error, for: tag, function: function)
    }
}
