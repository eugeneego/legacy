// Generated using Sourcery 0.16.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct UserAddressLightTransformer: LightTransformer {
    typealias T = User.Address

    let streetName = "street"
    let suiteName = "suite"
    let cityName = "city"
    let zipcodeName = "zipcode"
    let geoName = "geo"

    let streetTransformer = CastLightTransformer<String>()
    let suiteTransformer = CastLightTransformer<String>()
    let cityTransformer = CastLightTransformer<String>()
    let zipcodeTransformer = CastLightTransformer<String>()
    let geoTransformer = UserAddressGeoPointLightTransformer()

    func from(any value: Any?) -> T? {
        guard let dictionary = value as? [String: Any] else { return nil }

        guard let street = streetTransformer.from(any: dictionary[streetName]) else { return nil }
        guard let suite = suiteTransformer.from(any: dictionary[suiteName]) else { return nil }
        guard let city = cityTransformer.from(any: dictionary[cityName]) else { return nil }
        guard let zipcode = zipcodeTransformer.from(any: dictionary[zipcodeName]) else { return nil }
        guard let geo = geoTransformer.from(any: dictionary[geoName]) else { return nil }

        return T(
            street: street,
            suite: suite,
            city: city,
            zipcode: zipcode,
            geo: geo
        )
    }

    func to(any value: T?) -> Any? {
        guard let value = value else { return nil }

        var dictionary: [String: Any] = [:]
        dictionary[streetName] = streetTransformer.to(any: value.street)
        dictionary[suiteName] = suiteTransformer.to(any: value.suite)
        dictionary[cityName] = cityTransformer.to(any: value.city)
        dictionary[zipcodeName] = zipcodeTransformer.to(any: value.zipcode)
        dictionary[geoName] = geoTransformer.to(any: value.geo)
        return dictionary
    }
}
