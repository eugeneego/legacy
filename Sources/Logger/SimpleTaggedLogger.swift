//
// SimpleTaggedLogger
// Legacy
//
// Created by Alex Babaev on 03 May 2018.
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public class SimpleTaggedLogger: TaggedLogger {
    private let logger: Logger
    public let tag: String

    public init(logger: Logger, tag: String) {
        self.logger = logger
        self.tag = tag
    }

    public convenience init(logger: Logger, for object: Any) {
        self.init(logger: logger, tag: String(describing: type(of: object)))
    }

    public convenience init(logger: Logger, for type: Any.Type) {
        self.init(logger: logger, tag: String(describing: type))
    }

    public func log(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String],
        level: LoggingLevel,
        tag: String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        logger.log(message(), meta: meta(), level: level, tag: tag, file: file, function: function, line: line)
    }
}
