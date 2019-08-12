// Generated using Sourcery 0.16.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct UserAddressTransformer: Transformer {
    typealias Source = Any
    typealias Destination = User.Address

    let streetName = "street"
    let suiteName = "suite"
    let cityName = "city"
    let zipcodeName = "zipcode"
    let geoName = "geo"

    let streetTransformer = CastTransformer<Any, String>()
    let suiteTransformer = CastTransformer<Any, String>()
    let cityTransformer = CastTransformer<Any, String>()
    let zipcodeTransformer = CastTransformer<Any, String>()
    let geoTransformer = UserAddressGeoPointTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let streetResult = dictionary[streetName].map(streetTransformer.transform(source:)) ?? .failure(.requirement)
        let suiteResult = dictionary[suiteName].map(suiteTransformer.transform(source:)) ?? .failure(.requirement)
        let cityResult = dictionary[cityName].map(cityTransformer.transform(source:)) ?? .failure(.requirement)
        let zipcodeResult = dictionary[zipcodeName].map(zipcodeTransformer.transform(source:)) ?? .failure(.requirement)
        let geoResult = dictionary[geoName].map(geoTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        streetResult.error.map { errors.append((streetName, $0)) }
        suiteResult.error.map { errors.append((suiteName, $0)) }
        cityResult.error.map { errors.append((cityName, $0)) }
        zipcodeResult.error.map { errors.append((zipcodeName, $0)) }
        geoResult.error.map { errors.append((geoName, $0)) }

        guard
            let street = streetResult.value,
            let suite = suiteResult.value,
            let city = cityResult.value,
            let zipcode = zipcodeResult.value,
            let geo = geoResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                street: street,
                suite: suite,
                city: city,
                zipcode: zipcode,
                geo: geo
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let streetResult = streetTransformer.transform(destination: value.street)
        let suiteResult = suiteTransformer.transform(destination: value.suite)
        let cityResult = cityTransformer.transform(destination: value.city)
        let zipcodeResult = zipcodeTransformer.transform(destination: value.zipcode)
        let geoResult = geoTransformer.transform(destination: value.geo)

        var errors: [(String, TransformerError)] = []
        streetResult.error.map { errors.append((streetName, $0)) }
        suiteResult.error.map { errors.append((suiteName, $0)) }
        cityResult.error.map { errors.append((cityName, $0)) }
        zipcodeResult.error.map { errors.append((zipcodeName, $0)) }
        geoResult.error.map { errors.append((geoName, $0)) }

        guard
            let street = streetResult.value,
            let suite = suiteResult.value,
            let city = cityResult.value,
            let zipcode = zipcodeResult.value,
            let geo = geoResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[streetName] = street
        dictionary[suiteName] = suite
        dictionary[cityName] = city
        dictionary[zipcodeName] = zipcode
        dictionary[geoName] = geo
        return .success(dictionary)
    }
}
