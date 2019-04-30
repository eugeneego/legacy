//
// PrintLogger
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

/// Simple print logger. Output is similar to NSLogLogger, but does not have its limitations. Output goes to stdout.
public class PrintLogger: Logger {
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

    private let dateFormatter: DateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss.SSS ZZZZZ")

    public func log(
        _ message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: String],
        level: LoggingLevel,
        tag: String,
        function: String
    ) {
        print("\(dateFormatter.string(from: Date())) \(name(for: level)) \(tag)\(function.isEmpty ? "" : ".\(function)") \(message())")
    }
}
