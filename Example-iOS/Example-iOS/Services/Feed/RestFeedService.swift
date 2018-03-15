//
// RestFeedService
// Example-iOS
//
// Created by Eugene Egorov on 24 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import Legacy

class RestFeedService: FeedService {
    private let rest: LightRestClient

    init(rest: LightRestClient) {
        self.rest = rest
    }
}
