// Generated using Sourcery 0.16.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import Legacy

// swiftlint:disable line_length type_name function_body_length identifier_name
struct FeedKindLightTransformer: LightTransformer {
    typealias T = Feed.Kind

    private let transformer = CastLightTransformer<String>()

    func from(any value: Any?) -> T? {
        guard let rawValue = transformer.from(any: value) else { return nil }

        switch rawValue {
            case "news":
                return .news
            case "article":
                return .article
            case "tweet":
                return .tweet
            default:
                return nil
        }
    }

    func to(any value: T?) -> Any? {
        guard let value = value else { return nil }

        switch value {
            case .news:
                return transformer.to(any: "news")
            case .article:
                return transformer.to(any: "article")
            case .tweet:
                return transformer.to(any: "tweet")
        }
    }
}
// swiftlint:enable line_length type_name function_body_length identifier_name
