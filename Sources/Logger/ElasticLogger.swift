//
// ElasticLogger
// Legacy
//
// Created by Alexander Babaev.
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif

/// Logger that sends data to the backend using Elastic Search API.
public class ElasticLogger: Logger, @unchecked Sendable {
    private let environment: String
    private let userParameters: () -> [String: String]
    private let appAndSystemParameters: [String: String]
    private let sender: Sender

    public init(
        http: Http,
        baseUrl: URL,
        token: String,
        type: String,
        environment: String,
        deviceInfo: DeviceInfo,
        userParameters: @escaping () -> [String: String] = { [:] }
    ) {
        self.environment = environment
        self.userParameters = userParameters

        appAndSystemParameters = [
            "device": deviceInfo.machineName,
            "os": "\(deviceInfo.system) \(deviceInfo.systemVersion)",
            "app": deviceInfo.bundleIdentifier,
            "app_version": deviceInfo.bundleVersion,
            "app_build": deviceInfo.bundleBuild,
            "environment": environment,
        ]

        sender = Sender(http: http, baseUrl: baseUrl, token: token, type: type)
    }

    public func start() {
        Task {
            await sender.start()
        }
    }

    public func stop() {
        Task {
            await sender.stop()
        }
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()

    private func severity(for level: LoggingLevel) -> String {
        switch level {
        case .verbose:
            return "verbose"
        case .debug:
            return "debug"
        case .info:
            return "info"
        case .warning:
            return "warn"
        case .error:
            return "err"
        case .critical:
            return "crit"
        }
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
        let timestamp = ElasticLogger.timestampFormatter.string(from: Date())
        let message = message()
        let meta = meta()

        var logData: [String: String] = [
            "@timestamp": timestamp,
            "severity": severity(for: level),
            "tag": tag,
            "function": "\(function)",
            "message": message,
        ]
        meta.forEach { logData[$0.key] = $0.value }
        appAndSystemParameters.forEach { logData[$0.key] = $0.value }
        userParameters().forEach { logData[$0.key] = $0.value }

        Task { [logData] in
            await sender.add(logData: logData)
        }
    }

    private actor Sender {
        private let http: Http
        private let baseUrl: URL
        private let token: String
        private let type: String

        private var sendLogsTimer: Timer?
        private let sendLogsTimerDelay: TimeInterval = 5.0
        private let maxNumberOfLogs: Int = 1000
        private let maxNumberOfLogsToSendInBulk: Int = 20

        private var logsToSend: [[String: String]] = []
        private var sending: Bool = false

        init(http: Http, baseUrl: URL, token: String, type: String) {
            self.http = http
            self.baseUrl = baseUrl
            self.token = token
            self.type = type
        }

        func start() {
            if !logsToSend.isEmpty {
                startSendLogsTimer()
            }
        }

        func stop() {
            stopSendLogsTimer()
        }

        func add(logData: [String: String]) {
            logsToSend.append(logData)

            if logsToSend.count > maxNumberOfLogs {
                NSLog("Ⓛ Exceeded maximum log messages: \(maxNumberOfLogs)")
                logsToSend.removeSubrange(0 ..< (logsToSend.count - maxNumberOfLogs))
            }

            if !logsToSend.isEmpty && sendLogsTimer == nil {
                startSendLogsTimer()
            }
        }

        private func sendLogs() async {
            guard !sending else { return }
            guard !logsToSend.isEmpty else { return stopSendLogsTimer() }

            sending = true

            let logs = Array(logsToSend.prefix(maxNumberOfLogsToSendInBulk))
            logsToSend = Array(logsToSend.dropFirst(maxNumberOfLogsToSendInBulk))

            let path = logs.count == 1 ? "/\(token)/\(type)" : "/_bulk"
            let string = logs.count == 1 ? serialize(log: logs[0]) : serialize(logs: logs)
            let url = baseUrl.appendingPathComponent(path)

            guard let data = string?.data(using: .utf8) else {
                sending = false
                return
            }

            #if os(iOS) || os(tvOS)
            let taskId = await UIApplication.shared.beginBackgroundTask(withName: String(describing: Swift.type(of: self)))
            #endif

            let result = await http.data(parameters: .init(method: .post, url: url, body: .data(data)))

            sending = false

            if result.error != nil {
                logsToSend.insert(contentsOf: logs, at: 0)
            }

            #if os(iOS) || os(tvOS)
            await UIApplication.shared.endBackgroundTask(taskId)
            #endif
        }

        private func serialize(logs: [[String: String]]) -> String {
            let metaInfo = [
                "index": [
                    "_index": token,
                    "_type": type,
                ]
            ]

            guard let metaInfoLine = Json(value: metaInfo).string else { fatalError("Can't create meta info for elastic logs bulk update") }

            let result = logs.reduce("") { result, log in
                result + (serialize(log: log).map { "\(metaInfoLine)\n\($0)\n" } ?? "")
            }

            return result
        }

        private func serialize(log: [String: String]) -> String? {
            Json(value: log).string
        }

        private func startSendLogsTimer() {
            sendLogsTimer = Timer.scheduledTimer(withTimeInterval: sendLogsTimerDelay, repeats: true) { _ in
                Task { [weak self] in
                    await self?.sendLogs()
                }
            }
        }

        private func stopSendLogsTimer() {
            sendLogsTimer?.invalidate()
            sendLogsTimer = nil
        }
    }
}
