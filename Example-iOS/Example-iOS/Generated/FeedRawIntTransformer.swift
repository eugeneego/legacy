// Generated using Sourcery 0.16.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import Legacy

// swiftlint:disable line_length type_name function_body_length identifier_name
struct FeedRawIntTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Feed.RawInt

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 1:
                return .success(.one)
            case 3:
                return .success(.three)
            case 5:
                return .success(.five)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .one:
                return transformer.transform(destination: 1)
            case .three:
                return transformer.transform(destination: 3)
            case .five:
                return transformer.transform(destination: 5)
        }
    }
}
// swiftlint:enable line_length type_name function_body_length identifier_name
