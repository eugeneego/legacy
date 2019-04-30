// Generated using Sourcery 0.16.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable line_length type_name function_body_length identifier_name
struct PartialPostTransformer: Transformer {
    typealias Source = Any
    typealias Destination = PartialPost

    let userIdName = "userId"
    let idName = "id"
    let titleName = "title"
    let bodyName = "body"

    let userIdTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Int64>())
    let idTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Int64>())
    let titleTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let bodyTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let userIdResult = userIdTransformer.transform(source: dictionary[userIdName])
        let idResult = idTransformer.transform(source: dictionary[idName])
        let titleResult = titleTransformer.transform(source: dictionary[titleName])
        let bodyResult = bodyTransformer.transform(source: dictionary[bodyName])

        var errors: [(String, TransformerError)] = []
        userIdResult.error.map { errors.append((userIdName, $0)) }
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        bodyResult.error.map { errors.append((bodyName, $0)) }

        guard
            let userId = userIdResult.value,
            let id = idResult.value,
            let title = titleResult.value,
            let body = bodyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                userId: userId,
                id: id,
                title: title,
                body: body
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let userIdResult = userIdTransformer.transform(destination: value.userId)
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let bodyResult = bodyTransformer.transform(destination: value.body)

        var errors: [(String, TransformerError)] = []
        userIdResult.error.map { errors.append((userIdName, $0)) }
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        bodyResult.error.map { errors.append((bodyName, $0)) }

        guard
            let userId = userIdResult.value,
            let id = idResult.value,
            let title = titleResult.value,
            let body = bodyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[userIdName] = userId
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[bodyName] = body
        return .success(dictionary)
    }
}
// swiftlint:enable line_length type_name function_body_length identifier_name
