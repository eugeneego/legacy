//
// NetworkTestCase
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if !os(watchOS)

import Foundation
import XCTest
@testable import Legacy

class NetworkTestCase: XCTestCase {
    enum Constants {
        static let host: String = "https://jsonplaceholder.typicode.com"
        static let posts: String = "posts"
        static let users: String = "users"

        static let post: Post = Post(userId: 1, id: 1, title: "Title", body: "Body")
        static let partialPost: PartialPost = PartialPost(userId: nil, id: nil, title: "Updated Title", body: nil)
    }

    let rest: BaseRestClient = {
        guard let baseUrl = URL(string: Constants.host) else { fatalError("Invalid base url") }

        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let logger = DefaultUrlSessionHttpLogger(logger: PrintLogger())
        let http = UrlSessionHttp(configuration: configuration, logger: logger)
        let rest = BaseRestClient(http: http, baseUrl: baseUrl)
        return rest
    }()
}

#endif
