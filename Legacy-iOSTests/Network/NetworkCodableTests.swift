//
// NetworkCodableTests
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if !os(watchOS)

import Foundation
import XCTest
@testable import Legacy

class NetworkCodableTests: NetworkTestCase {
    // MARK: - Posts

    func testPostsRead() async {
        let task: NetworkTask<[Post]> = rest.read(path: Constants.posts, id: nil, parameters: [:], headers: [:])
        let result = await task.run()
        guard let posts = EEAssertSuccess(result, "Read Posts") else { return }
        XCTAssert(posts.count == 100)
    }

    func testPostRead() async {
        let task: NetworkTask<Post> = rest.read(path: Constants.posts, id: "1", parameters: [:], headers: [:])
        let result = await task.run()
        guard EEAssertSuccess(result, "Read Post") != nil else { return }
    }

    func testPostCreate() async {
        var object = Constants.post
        object.id = 0
        let task: NetworkTask<Post> = rest.create(path: Constants.posts, id: nil, object: object, headers: [:])
        let result = await task.run()
        guard let post = EEAssertSuccess(result, "Create Post") else { return }
        XCTAssert(post.userId == object.userId && post.title == object.title && post.body == object.body)
    }

    func testPostUpdate() async {
        let object = Constants.post
        let task: NetworkTask<Post> = rest.update(path: Constants.posts, id: "1", object: object, headers: [:])
        let result = await task.run()
        guard let post = EEAssertSuccess(result, "Update Post") else { return }
        XCTAssert(post.userId == object.userId && post.title == object.title && post.body == object.body)
    }

    func testPostPartialUpdate()  async {
        let object = Constants.partialPost
        let task: NetworkTask<Post> = rest.partialUpdate(path: Constants.posts, id: "1", object: object, headers: [:])
        let result = await task.run()
        guard let post = EEAssertSuccess(result, "Update Partial Post") else { return }
        XCTAssert(post.title == object.title)
    }

    func testPostDelete() async {
        let task: NetworkTask<Nil> = rest.delete(path: Constants.posts, id: "1", headers: [:])
        let result = await task.run()
        guard EEAssertSuccess(result, "Delete Post") != nil else { return }
    }

    // MARK: - Users

    func testUsersRead() async {
        let task: NetworkTask<[User]> = rest.read(path: Constants.users, id: nil, parameters: [:], headers: [:])
        let result = await task.run()
        guard let users = EEAssertSuccess(result, "Read Users") else { return }
        XCTAssert(users.count == 10)
    }

    func testUserRead() async {
        let task: NetworkTask<User> = rest.read(path: Constants.users, id: "1", parameters: [:], headers: [:])
        let result = await task.run()
        guard EEAssertSuccess(result, "Read User") != nil else { return }
    }
}

#endif
