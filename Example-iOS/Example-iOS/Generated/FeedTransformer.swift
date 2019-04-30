// Generated using Sourcery 0.16.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable line_length type_name function_body_length identifier_name
struct FeedTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Feed

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

    let idTransformer = CastTransformer<Any, String>()
    let kindTransformer = FeedKindTransformer()
    let rawKindTransformer = FeedRawKindTransformer()
    let subKindTransformer = OptionalTransformer(transformer: FeedKindTransformer())
    let titleTransformer = CastTransformer<Any, String>()
    let descriptionTransformer = CastTransformer<Any, String>()
    let createdTransformer = TimestampTransformer<Any>(scale: 1)
    let authorTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let tagsTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)
    let likesTransformer = NumberTransformer<Any, Int>()
    let subscriptionTransformer = FeedSubscriptionTransformer()
    let rawIntTransformer = FeedRawIntTransformer()
    let metaTransformer = DictionaryTransformer(from: Any.self, keyTransformer: CastTransformer<AnyHashable, String>(), valueTransformer: CastTransformer<Any, String>(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let kindResult = dictionary[kindName].map(kindTransformer.transform(source:)) ?? .failure(.requirement)
        let rawKindResult = dictionary[rawKindName].map(rawKindTransformer.transform(source:)) ?? .failure(.requirement)
        let subKindResult = subKindTransformer.transform(source: dictionary[subKindName])
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let createdResult = dictionary[createdName].map(createdTransformer.transform(source:)) ?? .failure(.requirement)
        let authorResult = authorTransformer.transform(source: dictionary[authorName])
        let tagsResult = dictionary[tagsName].map(tagsTransformer.transform(source:)) ?? .failure(.requirement)
        let likesResult = dictionary[likesName].map(likesTransformer.transform(source:)) ?? .failure(.requirement)
        let subscriptionResult = dictionary[subscriptionName].map(subscriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let rawIntResult = dictionary[rawIntName].map(rawIntTransformer.transform(source:)) ?? .failure(.requirement)
        let metaResult = dictionary[metaName].map(metaTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        kindResult.error.map { errors.append((kindName, $0)) }
        rawKindResult.error.map { errors.append((rawKindName, $0)) }
        subKindResult.error.map { errors.append((subKindName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        createdResult.error.map { errors.append((createdName, $0)) }
        authorResult.error.map { errors.append((authorName, $0)) }
        tagsResult.error.map { errors.append((tagsName, $0)) }
        likesResult.error.map { errors.append((likesName, $0)) }
        subscriptionResult.error.map { errors.append((subscriptionName, $0)) }
        rawIntResult.error.map { errors.append((rawIntName, $0)) }
        metaResult.error.map { errors.append((metaName, $0)) }

        guard
            let id = idResult.value,
            let kind = kindResult.value,
            let rawKind = rawKindResult.value,
            let subKind = subKindResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            let created = createdResult.value,
            let author = authorResult.value,
            let tags = tagsResult.value,
            let likes = likesResult.value,
            let subscription = subscriptionResult.value,
            let rawInt = rawIntResult.value,
            let meta = metaResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
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
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let kindResult = kindTransformer.transform(destination: value.kind)
        let rawKindResult = rawKindTransformer.transform(destination: value.rawKind)
        let subKindResult = subKindTransformer.transform(destination: value.subKind)
        let titleResult = titleTransformer.transform(destination: value.title)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let createdResult = createdTransformer.transform(destination: value.created)
        let authorResult = authorTransformer.transform(destination: value.author)
        let tagsResult = tagsTransformer.transform(destination: value.tags)
        let likesResult = likesTransformer.transform(destination: value.likes)
        let subscriptionResult = subscriptionTransformer.transform(destination: value.subscription)
        let rawIntResult = rawIntTransformer.transform(destination: value.rawInt)
        let metaResult = metaTransformer.transform(destination: value.meta)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        kindResult.error.map { errors.append((kindName, $0)) }
        rawKindResult.error.map { errors.append((rawKindName, $0)) }
        subKindResult.error.map { errors.append((subKindName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        createdResult.error.map { errors.append((createdName, $0)) }
        authorResult.error.map { errors.append((authorName, $0)) }
        tagsResult.error.map { errors.append((tagsName, $0)) }
        likesResult.error.map { errors.append((likesName, $0)) }
        subscriptionResult.error.map { errors.append((subscriptionName, $0)) }
        rawIntResult.error.map { errors.append((rawIntName, $0)) }
        metaResult.error.map { errors.append((metaName, $0)) }

        guard
            let id = idResult.value,
            let kind = kindResult.value,
            let rawKind = rawKindResult.value,
            let subKind = subKindResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            let created = createdResult.value,
            let author = authorResult.value,
            let tags = tagsResult.value,
            let likes = likesResult.value,
            let subscription = subscriptionResult.value,
            let rawInt = rawIntResult.value,
            let meta = metaResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[kindName] = kind
        dictionary[rawKindName] = rawKind
        dictionary[subKindName] = subKind
        dictionary[titleName] = title
        dictionary[descriptionName] = description
        dictionary[createdName] = created
        dictionary[authorName] = author
        dictionary[tagsName] = tags
        dictionary[likesName] = likes
        dictionary[subscriptionName] = subscription
        dictionary[rawIntName] = rawInt
        dictionary[metaName] = meta
        return .success(dictionary)
    }
}
// swiftlint:enable line_length type_name function_body_length identifier_name
