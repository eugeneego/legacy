//
// LoggerConfiguration
// Legacy
//
// Created by Alexander Babaev.
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public struct LoggerConfiguration {
    public var tagLoggingLevels: [String: LoggingConfigurationLevel]

    public init(tagLoggingLevels: [String: LoggingConfigurationLevel]) {
        self.tagLoggingLevels = tagLoggingLevels
    }
}
