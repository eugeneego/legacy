// Generated using Sourcery 0.6.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import CoreGraphics
import EEUtilities

// swiftlint:disable line_length
struct FeedTransformer: FullTransformer {
    typealias Source = Any
    typealias Destination = Feed

    let idName = "id"
    let kindName = "kind"
    let titleName = "title"
    let descriptionName = "description"
    let createdName = "created"
    let authorName = "author"
    let tagsName = "tags"
    let likesName = "likes"
    let subscriptionName = "subscription"

    let idTransformer = CastTransformer<Any, String>()
    let kindTransformer = FeedKindTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let descriptionTransformer = CastTransformer<Any, String>()
    let createdTransformer = TimestampTransformer<Any>()
    let authorTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let tagsTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)
    let likesTransformer = CastTransformer<Any, Int>()
    let subscriptionTransformer = FeedSubscriptionTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let kindResult = dictionary[kindName].map(kindTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let createdResult = dictionary[createdName].map(createdTransformer.transform(source:)) ?? .failure(.requirement)
        let authorResult = authorTransformer.transform(source: dictionary[authorName])
        let tagsResult = dictionary[tagsName].map(tagsTransformer.transform(source:)) ?? .failure(.requirement)
        let likesResult = dictionary[likesName].map(likesTransformer.transform(source:)) ?? .failure(.requirement)
        let subscriptionResult = dictionary[subscriptionName].map(subscriptionTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        kindResult.error.map { errors.append((kindName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        createdResult.error.map { errors.append((createdName, $0)) }
        authorResult.error.map { errors.append((authorName, $0)) }
        tagsResult.error.map { errors.append((tagsName, $0)) }
        likesResult.error.map { errors.append((likesName, $0)) }
        subscriptionResult.error.map { errors.append((subscriptionName, $0)) }

        guard
            let id = idResult.value,
            let kind = kindResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            let created = createdResult.value,
            let author = authorResult.value,
            let tags = tagsResult.value,
            let likes = likesResult.value,
            let subscription = subscriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                kind: kind,
                title: title,
                description: description,
                created: created,
                author: author,
                tags: tags,
                likes: likes,
                subscription: subscription
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let kindResult = kindTransformer.transform(destination: value.kind)
        let titleResult = titleTransformer.transform(destination: value.title)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let createdResult = createdTransformer.transform(destination: value.created)
        let authorResult = authorTransformer.transform(destination: value.author)
        let tagsResult = tagsTransformer.transform(destination: value.tags)
        let likesResult = likesTransformer.transform(destination: value.likes)
        let subscriptionResult = subscriptionTransformer.transform(destination: value.subscription)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        kindResult.error.map { errors.append((kindName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        createdResult.error.map { errors.append((createdName, $0)) }
        authorResult.error.map { errors.append((authorName, $0)) }
        tagsResult.error.map { errors.append((tagsName, $0)) }
        likesResult.error.map { errors.append((likesName, $0)) }
        subscriptionResult.error.map { errors.append((subscriptionName, $0)) }

        guard
            let id = idResult.value,
            let kind = kindResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            let created = createdResult.value,
            let author = authorResult.value,
            let tags = tagsResult.value,
            let likes = likesResult.value,
            let subscription = subscriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[kindName] = kind
        dictionary[titleName] = title
        dictionary[descriptionName] = description
        dictionary[createdName] = created
        dictionary[authorName] = author
        dictionary[tagsName] = tags
        dictionary[likesName] = likes
        dictionary[subscriptionName] = subscription
        return .success(dictionary)
    }
}
// swiftlint:enable line_length
