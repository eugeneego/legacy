//
// Feed
// Example-iOS
//
// Created by Eugene Egorov on 24 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import Foundation

// sourcery: transformer
// sourcery: lightTransformer
struct Feed {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    // sourcery: enumLightTransformer, enumLightTransformer.type = "String"
    enum Kind {
        // sourcery: enumTransformer.value = "NEWS"
        case news
        // sourcery: enumTransformer.value = "ARTICLE"
        case article
        // sourcery: enumTransformer.value = "TWEET"
        case tweet
    }

    // sourcery: enumTransformer
    // sourcery: enumLightTransformer
    enum RawKind: String {
        case news = "NEWS"
        case article = "ARTICLE"
        case tweet = "TWEET"
    }

    // sourcery: enumTransformer, enumTransformer.type = "Int"
    // sourcery: enumLightTransformer, enumLightTransformer.type = "Int"
    enum Subscription {
        // sourcery: enumTransformer.value = 0
        // sourcery: enumLightTransformer.value = 0
        case none
        // sourcery: enumTransformer.value = 1
        // sourcery: enumLightTransformer.value = 1
        case posts
        // sourcery: enumTransformer.value = 2
        // sourcery: enumLightTransformer.value = 2
        case comments
    }

    // sourcery: enumTransformer
    // sourcery: enumLightTransformer
    enum RawInt: Int {
        case one = 1
        case three = 3
        case five = 5
    }

    var id: String
    var kind: Kind
    var rawKind: RawKind
    var subKind: Kind?
    var title: String
    var description: String
    // sourcery: transformer = "TimestampTransformer<Any>(scale: 1)"
    // sourcery: lightTransformer = "TimestampLightTransformer(scale: 1)"
    var created: Date
    var author: String?
    var tags: [String]
    var likes: Int
    var subscription: Subscription
    var rawInt: RawInt
    var meta: [String: String]
}
