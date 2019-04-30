// Generated using Sourcery 0.16.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable line_length type_name function_body_length identifier_name
struct FeedLightTransformer: LightTransformer {
    typealias T = Feed

    let idName = "id"
    let kindName = "kind"
    let rawKindName = "rawKind"
    let subKindName = "subKind"
    let titleName = "title"
    let descriptionName = "description"
    let createdName = "created"
    let authorName = "author"
    let tagsName = "tags"
    let likesName = "likes"
    let subscriptionName = "subscription"
    let rawIntName = "rawInt"
    let metaName = "meta"

    let idTransformer = CastLightTransformer<String>()
    let kindTransformer = FeedKindLightTransformer()
    let rawKindTransformer = FeedRawKindLightTransformer()
    let subKindTransformer = FeedKindLightTransformer()
    let titleTransformer = CastLightTransformer<String>()
    let descriptionTransformer = CastLightTransformer<String>()
    let createdTransformer = TimestampLightTransformer(scale: 1)
    let authorTransformer = CastLightTransformer<String>()
    let tagsTransformer = ArrayLightTransformer(transformer: CastLightTransformer<String>())
    let likesTransformer = NumberLightTransformer<Int>()
    let subscriptionTransformer = FeedSubscriptionLightTransformer()
    let rawIntTransformer = FeedRawIntLightTransformer()
    let metaTransformer = DictionaryLightTransformer(keyTransformer: CastLightTransformer<String>(), valueTransformer: CastLightTransformer<String>())

    func from(any value: Any?) -> T? {
        guard let dictionary = value as? [String: Any] else { return nil }

        guard let id = idTransformer.from(any: dictionary[idName]) else { return nil }
        guard let kind = kindTransformer.from(any: dictionary[kindName]) else { return nil }
        guard let rawKind = rawKindTransformer.from(any: dictionary[rawKindName]) else { return nil }
        let subKind = subKindTransformer.from(any: dictionary[subKindName])
        guard let title = titleTransformer.from(any: dictionary[titleName]) else { return nil }
        guard let description = descriptionTransformer.from(any: dictionary[descriptionName]) else { return nil }
        guard let created = createdTransformer.from(any: dictionary[createdName]) else { return nil }
        let author = authorTransformer.from(any: dictionary[authorName])
        guard let tags = tagsTransformer.from(any: dictionary[tagsName]) else { return nil }
        guard let likes = likesTransformer.from(any: dictionary[likesName]) else { return nil }
        guard let subscription = subscriptionTransformer.from(any: dictionary[subscriptionName]) else { return nil }
        guard let rawInt = rawIntTransformer.from(any: dictionary[rawIntName]) else { return nil }
        guard let meta = metaTransformer.from(any: dictionary[metaName]) else { return nil }

        return T(
            id: id,
            kind: kind,
            rawKind: rawKind,
            subKind: subKind,
            title: title,
            description: description,
            created: created,
            author: author,
            tags: tags,
            likes: likes,
            subscription: subscription,
            rawInt: rawInt,
            meta: meta
        )
    }

    func to(any value: T?) -> Any? {
        guard let value = value else { return nil }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = idTransformer.to(any: value.id)
        dictionary[kindName] = kindTransformer.to(any: value.kind)
        dictionary[rawKindName] = rawKindTransformer.to(any: value.rawKind)
        dictionary[subKindName] = subKindTransformer.to(any: value.subKind)
        dictionary[titleName] = titleTransformer.to(any: value.title)
        dictionary[descriptionName] = descriptionTransformer.to(any: value.description)
        dictionary[createdName] = createdTransformer.to(any: value.created)
        dictionary[authorName] = authorTransformer.to(any: value.author)
        dictionary[tagsName] = tagsTransformer.to(any: value.tags)
        dictionary[likesName] = likesTransformer.to(any: value.likes)
        dictionary[subscriptionName] = subscriptionTransformer.to(any: value.subscription)
        dictionary[rawIntName] = rawIntTransformer.to(any: value.rawInt)
        dictionary[metaName] = metaTransformer.to(any: value.meta)
        return dictionary
    }
}
// swiftlint:enable line_length type_name function_body_length identifier_name
