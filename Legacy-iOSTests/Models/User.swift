//
// User
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

// sourcery: transformer
// sourcery: lightTransformer
struct User: Codable {
    var id: Int64
    var name: String
    var username: String
    var email: String
    var address: Address
    var phone: String
    var website: String
    var company: Company

    // sourcery: transformer
    // sourcery: lightTransformer
    struct Company: Codable {
        var name: String
        var catchPhrase: String
        var bs: String // swiftlint:disable:this identifier_name
    }

    // sourcery: transformer
    // sourcery: lightTransformer
    struct Address: Codable {
        var street: String
        var suite: String
        var city: String
        var zipcode: String
        var geo: GeoPoint

        // sourcery: transformer
        // sourcery: lightTransformer
        struct GeoPoint: Codable {
            var lat: String
            var lng: String
        }
    }
}
