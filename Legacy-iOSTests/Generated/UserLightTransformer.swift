// Generated using Sourcery 0.16.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct UserLightTransformer: LightTransformer {
    typealias T = User

    let idName = "id"
    let nameName = "name"
    let usernameName = "username"
    let emailName = "email"
    let addressName = "address"
    let phoneName = "phone"
    let websiteName = "website"
    let companyName = "company"

    let idTransformer = NumberLightTransformer<Int64>()
    let nameTransformer = CastLightTransformer<String>()
    let usernameTransformer = CastLightTransformer<String>()
    let emailTransformer = CastLightTransformer<String>()
    let addressTransformer = UserAddressLightTransformer()
    let phoneTransformer = CastLightTransformer<String>()
    let websiteTransformer = CastLightTransformer<String>()
    let companyTransformer = UserCompanyLightTransformer()

    func from(any value: Any?) -> T? {
        guard let dictionary = value as? [String: Any] else { return nil }

        guard let id = idTransformer.from(any: dictionary[idName]) else { return nil }
        guard let name = nameTransformer.from(any: dictionary[nameName]) else { return nil }
        guard let username = usernameTransformer.from(any: dictionary[usernameName]) else { return nil }
        guard let email = emailTransformer.from(any: dictionary[emailName]) else { return nil }
        guard let address = addressTransformer.from(any: dictionary[addressName]) else { return nil }
        guard let phone = phoneTransformer.from(any: dictionary[phoneName]) else { return nil }
        guard let website = websiteTransformer.from(any: dictionary[websiteName]) else { return nil }
        guard let company = companyTransformer.from(any: dictionary[companyName]) else { return nil }

        return T(
            id: id,
            name: name,
            username: username,
            email: email,
            address: address,
            phone: phone,
            website: website,
            company: company
        )
    }

    func to(any value: T?) -> Any? {
        guard let value = value else { return nil }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = idTransformer.to(any: value.id)
        dictionary[nameName] = nameTransformer.to(any: value.name)
        dictionary[usernameName] = usernameTransformer.to(any: value.username)
        dictionary[emailName] = emailTransformer.to(any: value.email)
        dictionary[addressName] = addressTransformer.to(any: value.address)
        dictionary[phoneName] = phoneTransformer.to(any: value.phone)
        dictionary[websiteName] = websiteTransformer.to(any: value.website)
        dictionary[companyName] = companyTransformer.to(any: value.company)
        return dictionary
    }
}
