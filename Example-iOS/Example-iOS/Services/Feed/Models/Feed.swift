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

    var id: String
    var kind: Kind
    var title: String
    var description: String
    // sourcery: transformer = TimestampTransformer<Any>()
    // sourcery: lightTransformer = TimestampLightTransformer()
    var created: Date
    var author: String?
    var tags: [String]
    var likes: Int
    var subscription: Subscription
}
