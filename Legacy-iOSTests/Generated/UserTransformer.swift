// Generated using Sourcery 0.10.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable line_length type_name function_body_length identifier_name
struct UserTransformer: FullTransformer {
    typealias Source = Any
    typealias Destination = User

    let idName = "id"
    let nameName = "name"
    let usernameName = "username"
    let emailName = "email"
    let addressName = "address"
    let phoneName = "phone"
    let websiteName = "website"
    let companyName = "company"

    let idTransformer = CastTransformer<Any, Int64>()
    let nameTransformer = CastTransformer<Any, String>()
    let usernameTransformer = CastTransformer<Any, String>()
    let emailTransformer = CastTransformer<Any, String>()
    let addressTransformer = UserAddressTransformer()
    let phoneTransformer = CastTransformer<Any, String>()
    let websiteTransformer = CastTransformer<Any, String>()
    let companyTransformer = UserCompanyTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let nameResult = dictionary[nameName].map(nameTransformer.transform(source:)) ?? .failure(.requirement)
        let usernameResult = dictionary[usernameName].map(usernameTransformer.transform(source:)) ?? .failure(.requirement)
        let emailResult = dictionary[emailName].map(emailTransformer.transform(source:)) ?? .failure(.requirement)
        let addressResult = dictionary[addressName].map(addressTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let websiteResult = dictionary[websiteName].map(websiteTransformer.transform(source:)) ?? .failure(.requirement)
        let companyResult = dictionary[companyName].map(companyTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        nameResult.error.map { errors.append((nameName, $0)) }
        usernameResult.error.map { errors.append((usernameName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        websiteResult.error.map { errors.append((websiteName, $0)) }
        companyResult.error.map { errors.append((companyName, $0)) }

        guard
            let id = idResult.value,
            let name = nameResult.value,
            let username = usernameResult.value,
            let email = emailResult.value,
            let address = addressResult.value,
            let phone = phoneResult.value,
            let website = websiteResult.value,
            let company = companyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                name: name,
                username: username,
                email: email,
                address: address,
                phone: phone,
                website: website,
                company: company
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let nameResult = nameTransformer.transform(destination: value.name)
        let usernameResult = usernameTransformer.transform(destination: value.username)
        let emailResult = emailTransformer.transform(destination: value.email)
        let addressResult = addressTransformer.transform(destination: value.address)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let websiteResult = websiteTransformer.transform(destination: value.website)
        let companyResult = companyTransformer.transform(destination: value.company)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        nameResult.error.map { errors.append((nameName, $0)) }
        usernameResult.error.map { errors.append((usernameName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        websiteResult.error.map { errors.append((websiteName, $0)) }
        companyResult.error.map { errors.append((companyName, $0)) }

        guard
            let id = idResult.value,
            let name = nameResult.value,
            let username = usernameResult.value,
            let email = emailResult.value,
            let address = addressResult.value,
            let phone = phoneResult.value,
            let website = websiteResult.value,
            let company = companyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[nameName] = name
        dictionary[usernameName] = username
        dictionary[emailName] = email
        dictionary[addressName] = address
        dictionary[phoneName] = phone
        dictionary[websiteName] = website
        dictionary[companyName] = company
        return .success(dictionary)
    }
}
// swiftlint:enable line_length type_name function_body_length identifier_name
