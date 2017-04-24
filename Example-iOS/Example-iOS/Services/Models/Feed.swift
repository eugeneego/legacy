//
// Feed
// Example-iOS
//
// Created by Eugene Egorov on 24 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import Foundation

// sourcery: transformer
struct Feed {
    var id: String
    var title: String
    var description: String
    var created: Date
    var author: String?
    var tags: [String]
    var likes: Int
}
