//
// NetworkFullTransformerTests
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation
import XCTest
@testable import Legacy

class NetworkFullTransformerTests: NetworkTestCase {
    // MARK: - Posts

    func testPostsRead() {
        expect("Read Posts") { description, expectation in
            rest.read(
                path: Constants.posts, id: nil, parameters: [:], headers: [:],
                responseTransformer: ArrayTransformer(transformer: PostTransformer())
            ) { result in
                guard let posts = EEAssertSuccess(result, description, expectation) else { return }

                XCTAssert(posts.count == 100)
                expectation.fulfill()
            }
        }
    }

    func testPostRead() {
        expect("Read Post") { description, expectation in
            rest.read(
                path: Constants.posts, id: "1", parameters: [:], headers: [:],
                responseTransformer: PostTransformer()
            ) { result in
                guard EEAssertSuccess(result, description, expectation) != nil else { return }

                expectation.fulfill()
            }
        }
    }

    func testPostCreate() {
        expect("Create Post") { description, expectation in
            var object = Constants.post
            object.id = 0
            rest.create(
                path: Constants.posts, id: nil, object: object, headers: [:],
                requestTransformer: PostTransformer(), responseTransformer: PostTransformer()
            ) { result in
                guard let post = EEAssertSuccess(result, description, expectation) else { return }

                XCTAssert(post.userId == object.userId && post.title == object.title && post.body == object.body)
                expectation.fulfill()
            }
        }
    }

    func testPostUpdate() {
        expect("Update Post") { description, expectation in
            let object = Constants.post
            rest.update(
                path: Constants.posts, id: "1", object: object, headers: [:],
                requestTransformer: PostTransformer(), responseTransformer: PostTransformer()
            ) { result in
                guard let post = EEAssertSuccess(result, description, expectation) else { return }

                XCTAssert(post.userId == object.userId && post.title == object.title && post.body == object.body)
                expectation.fulfill()
            }
        }
    }

    func testPostDelete() {
        expect("Delete Post") { description, expectation in
            rest.delete(
                path: Constants.posts, id: "1", headers: [:],
                responseTransformer: VoidTransformer<Any>()
            ) { result in
                guard EEAssertSuccess(result, description, expectation) != nil else { return }

                expectation.fulfill()
            }
        }
    }

    // MARK: - Users

    func testUsersRead() {
        expect("Read Users") { description, expectation in
            rest.read(
                path: Constants.users, id: nil, parameters: [:], headers: [:],
                responseTransformer: ArrayTransformer(transformer: UserTransformer())
            ) { result in
                guard let users = EEAssertSuccess(result, description, expectation) else { return }

                XCTAssert(users.count == 10)
                expectation.fulfill()
            }
        }
    }

    func testUserRead() {
        expect("Read User") { description, expectation in
            rest.read(
                path: Constants.users, id: "1", parameters: [:], headers: [:],
                responseTransformer: UserTransformer()
            ) { result in
                guard EEAssertSuccess(result, description, expectation) != nil else { return }

                expectation.fulfill()
            }
        }
    }
}
