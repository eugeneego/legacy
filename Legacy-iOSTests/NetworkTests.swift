//
// NetworkTests
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation
import XCTest
@testable import Legacy

class NetworkTests: EETestCase {
    let rest: BaseRestClient = {
        guard let baseUrl = URL(string: "https://jsonplaceholder.typicode.com") else { fatalError("Invalid base url") }

        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        let queue = DispatchQueue.global(qos: .default)
        let http = UrlSessionHttp(configuration: configuration, responseQueue: queue, logger: nil)
        let rest = BaseRestClient(http: http, baseURL: baseUrl, workQueue: queue, completionQueue: DispatchQueue.main)
        return rest
    }()

    // MARK: - Posts

    func testCodableReadPosts() {
        expect("Read Codable Posts") { description, expectation in
            rest.read(path: "posts", id: nil, parameters: [:], headers: [:]) { (result: Result<[Post], NetworkError>) in
                guard let posts = EEAssertSuccess(result, description, expectation) else { return }

                XCTAssert(posts.count == 100)
                expectation.fulfill()
            }
        }
    }

    func testLightTransformerReadPosts() {
        expect("Read Light Transformer Posts") { description, expectation in
            rest.read(
                path: "posts", id: nil, parameters: [:], headers: [:],
                responseTransformer: ArrayLightTransformer(transformer: PostLightTransformer())
            ) { result in
                guard let posts = EEAssertSuccess(result, description, expectation) else { return }

                XCTAssert(posts.count == 100)
                expectation.fulfill()
            }
        }
    }

    func testFullTransformerReadPosts() {
        expect("Read Full Transformer Posts") { description, expectation in
            rest.read(
                path: "posts", id: nil, parameters: [:], headers: [:],
                responseTransformer: ArrayTransformer(transformer: PostTransformer())
            ) { result in
                guard let posts = EEAssertSuccess(result, description, expectation) else { return }

                XCTAssert(posts.count == 100)
                expectation.fulfill()
            }
        }
    }

    // MARK: - Users

    func testCodableReadUsers() {
        expect("Read Codable Users") { description, expectation in
            rest.read(path: "users", id: nil, parameters: [:], headers: [:]) { (result: Result<[User], NetworkError>) in
                guard let users = EEAssertSuccess(result, description, expectation) else { return }

                XCTAssert(users.count == 10)
                expectation.fulfill()
            }
        }
    }

    func testLightTransformerReadUsers() {
        expect("Read Light Transformer Users") { description, expectation in
            rest.read(
                path: "users", id: nil, parameters: [:], headers: [:],
                responseTransformer: ArrayLightTransformer(transformer: UserLightTransformer())
            ) { result in
                guard let users = EEAssertSuccess(result, description, expectation) else { return }

                XCTAssert(users.count == 10)
                expectation.fulfill()
            }
        }
    }

    func testFullTransformerReadUsers() {
        expect("Read Full Transformer Users") { description, expectation in
            rest.read(
                path: "users", id: nil, parameters: [:], headers: [:],
                responseTransformer: ArrayTransformer(transformer: UserTransformer())
            ) { result in
                guard let users = EEAssertSuccess(result, description, expectation) else { return }

                XCTAssert(users.count == 10)
                expectation.fulfill()
            }
        }
    }
}
