// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable line_length type_name function_body_length identifier_name
struct UserAddressGeoPointTransformer: Transformer {
    typealias Source = Any
    typealias Destination = User.Address.GeoPoint

    let latName = "lat"
    let lngName = "lng"

    let latTransformer = CastTransformer<Any, String>()
    let lngTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let latResult = dictionary[latName].map(latTransformer.transform(source:)) ?? .failure(.requirement)
        let lngResult = dictionary[lngName].map(lngTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        latResult.error.map { errors.append((latName, $0)) }
        lngResult.error.map { errors.append((lngName, $0)) }

        guard
            let lat = latResult.value,
            let lng = lngResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                lat: lat,
                lng: lng
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let latResult = latTransformer.transform(destination: value.lat)
        let lngResult = lngTransformer.transform(destination: value.lng)

        var errors: [(String, TransformerError)] = []
        latResult.error.map { errors.append((latName, $0)) }
        lngResult.error.map { errors.append((lngName, $0)) }

        guard
            let lat = latResult.value,
            let lng = lngResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[latName] = lat
        dictionary[lngName] = lng
        return .success(dictionary)
    }
}
// swiftlint:enable line_length type_name function_body_length identifier_name
