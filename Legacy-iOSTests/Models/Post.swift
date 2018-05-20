//
// Post
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

// sourcery: transformer
// sourcery: lightTransformer
struct Post: Codable {
    var userId: Int64
    var id: Int64
    var title: String
    var body: String
}
