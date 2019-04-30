// Generated using Sourcery 0.16.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import Legacy

// swiftlint:disable line_length type_name function_body_length identifier_name
struct FeedSubscriptionLightTransformer: LightTransformer {
    typealias T = Feed.Subscription

    private let transformer = NumberLightTransformer<Int>()

    func from(any value: Any?) -> T? {
        guard let rawValue = transformer.from(any: value) else { return nil }

        switch rawValue {
            case 0:
                return .none
            case 1:
                return .posts
            case 2:
                return .comments
            default:
                return nil
        }
    }

    func to(any value: T?) -> Any? {
        guard let value = value else { return nil }

        switch value {
            case .none:
                return transformer.to(any: 0)
            case .posts:
                return transformer.to(any: 1)
            case .comments:
                return transformer.to(any: 2)
        }
    }
}
// swiftlint:enable line_length type_name function_body_length identifier_name
