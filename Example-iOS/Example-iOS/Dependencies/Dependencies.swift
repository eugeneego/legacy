//
// Dependencies
// Example-iOS
//
// Created by Eugene Egorov on 29 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import Legacy

protocol DependencyContainerDependency {
    var container: DependencyInjectionContainer! { get set }
}

protocol LoggerDependency {
    var logger: Logger! { get set }
}

protocol FeedServiceDependency {
    var feedService: FeedService! { get set }
}

protocol ImageLoaderDependency {
    var imageLoader: ImageLoader! { get set }
}
