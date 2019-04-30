// Generated using Sourcery 0.16.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import Legacy

// swiftlint:disable line_length type_name function_body_length identifier_name
struct FeedRawKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Feed.RawKind

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "NEWS":
                return .success(.news)
            case "ARTICLE":
                return .success(.article)
            case "TWEET":
                return .success(.tweet)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .news:
                return transformer.transform(destination: "NEWS")
            case .article:
                return transformer.transform(destination: "ARTICLE")
            case .tweet:
                return transformer.transform(destination: "TWEET")
        }
    }
}
// swiftlint:enable line_length type_name function_body_length identifier_name
