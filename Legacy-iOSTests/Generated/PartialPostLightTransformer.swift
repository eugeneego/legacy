// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct PartialPostLightTransformer: LightTransformer {
    typealias T = PartialPost

    let userIdName = "userId"
    let idName = "id"
    let titleName = "title"
    let bodyName = "body"

    let userIdTransformer = NumberLightTransformer<Int64>()
    let idTransformer = NumberLightTransformer<Int64>()
    let titleTransformer = CastLightTransformer<String>()
    let bodyTransformer = CastLightTransformer<String>()

    func from(any value: Any?) -> T? {
        guard let dictionary = value as? [String: Any] else { return nil }

        let userId = userIdTransformer.from(any: dictionary[userIdName])
        let id = idTransformer.from(any: dictionary[idName])
        let title = titleTransformer.from(any: dictionary[titleName])
        let body = bodyTransformer.from(any: dictionary[bodyName])

        return T(
            userId: userId,
            id: id,
            title: title,
            body: body
        )
    }

    func to(any value: T?) -> Any? {
        guard let value = value else { return nil }

        var dictionary: [String: Any] = [:]
        dictionary[userIdName] = userIdTransformer.to(any: value.userId)
        dictionary[idName] = idTransformer.to(any: value.id)
        dictionary[titleName] = titleTransformer.to(any: value.title)
        dictionary[bodyName] = bodyTransformer.to(any: value.body)
        return dictionary
    }
}
// swiftlint:enable all
