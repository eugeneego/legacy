// Generated using Sourcery 0.16.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import Legacy

// swiftlint:disable line_length type_name function_body_length identifier_name
struct FeedRawKindLightTransformer: LightTransformer {
    typealias T = Feed.RawKind

    private let transformer = CastLightTransformer<String>()

    func from(any value: Any?) -> T? {
        guard let rawValue = transformer.from(any: value) else { return nil }

        switch rawValue {
            case "NEWS":
                return .news
            case "ARTICLE":
                return .article
            case "TWEET":
                return .tweet
            default:
                return nil
        }
    }

    func to(any value: T?) -> Any? {
        guard let value = value else { return nil }

        switch value {
            case .news:
                return transformer.to(any: "NEWS")
            case .article:
                return transformer.to(any: "ARTICLE")
            case .tweet:
                return transformer.to(any: "TWEET")
        }
    }
}
// swiftlint:enable line_length type_name function_body_length identifier_name
