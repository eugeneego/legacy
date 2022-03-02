//
// FilteringLogger
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

/// Logger that can filter log messages by levels and process only ones that have "higher error level" than specified.
/// Levels can be specified for each tag separately.
public class FilteringLogger: Logger {
    private let logger: Logger
    private let tagLevels: [String: LoggingLevel?]
    private let defaultLevel: LoggingLevel?

    public init(logger: Logger, tagLevels: [String: LoggingLevel?], defaultLevel: LoggingLevel?) {
        self.logger = logger
        self.tagLevels = tagLevels
        self.defaultLevel = defaultLevel
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
        guard let filteringLevel = tagLevels[tag] ?? defaultLevel, level.rawValue >= filteringLevel.rawValue  else { return }
        logger.log(message(), meta: meta(), level: level, tag: tag, file: file, function: function, line: line)
    }
}
