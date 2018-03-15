// Generated using Sourcery 0.10.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import Legacy

// swiftlint:disable line_length type_name function_body_length
struct FeedSubscriptionTransformer<From>: FullTransformer {
    typealias Source = From
    typealias Destination = Feed.Subscription

    private let transformer = CastTransformer<From, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.none)
            case 1:
                return .success(.posts)
            case 2:
                return .success(.comments)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .none:
                return transformer.transform(destination: 0)
            case .posts:
                return transformer.transform(destination: 1)
            case .comments:
                return transformer.transform(destination: 2)
        }
    }
}
// swiftlint:enable line_length type_name function_body_length
