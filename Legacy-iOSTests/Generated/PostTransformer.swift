// Generated using Sourcery 0.10.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable line_length type_name function_body_length identifier_name
struct PostTransformer: FullTransformer {
    typealias Source = Any
    typealias Destination = Post

    let userIdName = "userId"
    let idName = "id"
    let titleName = "title"
    let bodyName = "body"

    let userIdTransformer = CastTransformer<Any, Int64>()
    let idTransformer = CastTransformer<Any, Int64>()
    let titleTransformer = CastTransformer<Any, String>()
    let bodyTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let userIdResult = dictionary[userIdName].map(userIdTransformer.transform(source:)) ?? .failure(.requirement)
        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let bodyResult = dictionary[bodyName].map(bodyTransformer.transform(source:)) ?? .failure(.requirement)

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
