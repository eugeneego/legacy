//
// NetworkCodableAsyncTests
// Legacy
//
// Copyright (c) 2022 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if !os(watchOS)

import Foundation
import XCTest
@testable import Legacy

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
class NetworkCodableAsyncTests: NetworkTestCase {
    // MARK: - Posts

    func testPostsRead() async {
        let result: Result<[Post], NetworkError> = await rest.read(path: Constants.posts, id: nil, parameters: [:], headers: [:])
        guard let posts = EEAssertSuccess(result, "Read Posts") else { return }
        XCTAssert(posts.count == 100)
    }

    func testPostRead() async {
        let result: Result<Post, NetworkError> = await rest.read(path: Constants.posts, id: "1", parameters: [:], headers: [:])
        EEAssertSuccess(result, "Read Post")
    }

    func testPostCreate() async {
        var object = Constants.post
        object.id = 0
        let result: Result<Post, NetworkError> = await rest.create(path: Constants.posts, id: nil, object: object, headers: [:])
        guard let post = EEAssertSuccess(result, "Create Post") else { return }
        XCTAssert(post.userId == object.userId && post.title == object.title && post.body == object.body)
    }

    func testPostUpdate() async {
        let object = Constants.post
        let result: Result<Post, NetworkError> = await rest.update(path: Constants.posts, id: "1", object: object, headers: [:])
        guard let post = EEAssertSuccess(result, "Update Post") else { return }
        XCTAssert(post.userId == object.userId && post.title == object.title && post.body == object.body)
    }

    func testPostPartialUpdate() async {
        let object = Constants.partialPost
        let result: Result<Post, NetworkError> = await rest.partialUpdate(path: Constants.posts, id: "1", object: object, headers: [:])
        guard let post = EEAssertSuccess(result, "Update Partial Post") else { return }
        XCTAssert(post.title == object.title)
    }

    func testPostDelete() async {
        let result: Result<Nil, NetworkError> = await rest.delete(path: Constants.posts, id: "1", headers: [:])
        EEAssertSuccess(result, "Delete Post")
    }

    // MARK: - Users

    func testUsersRead() async {
        let result: Result<[User], NetworkError> = await rest.read(path: Constants.users, id: nil, parameters: [:], headers: [:])
        guard let users = EEAssertSuccess(result, "Read Users") else { return }
        XCTAssert(users.count == 10)
    }

    func testUserRead() async {
        let result: Result<User, NetworkError> = await rest.read(path: Constants.users, id: "1", parameters: [:], headers: [:])
        EEAssertSuccess(result, "Read User")
    }
}

#endif
