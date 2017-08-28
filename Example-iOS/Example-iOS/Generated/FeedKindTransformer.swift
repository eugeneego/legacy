// Generated using Sourcery 0.6.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import EEUtilities

// swiftlint:disable line_length type_name function_body_length
struct FeedKindTransformer<From>: FullTransformer {
    typealias Source = From
    typealias Destination = Feed.Kind

    private let transformer = CastTransformer<From, String>()

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
// swiftlint:enable line_length type_name function_body_length
