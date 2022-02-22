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
    private let tagLevels: [String: Level]
    private let defaultLevel: Level

    public struct Level {
        public var value: LoggingLevel?

        public init(_ value: LoggingLevel?) {
            self.value = value
        }
    }

    public init(logger: Logger, tagLevels: [String: Level], defaultLevel: Level) {
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
        let filteringLevel = tagLevels[tag] ?? defaultLevel
        guard let filteringLoggingLevel = filteringLevel.value, level.rawValue >= filteringLoggingLevel.rawValue  else { return }

        logger.log(message(), meta: meta(), level: level, tag: tag, file: file, function: function, line: line)
    }
}
