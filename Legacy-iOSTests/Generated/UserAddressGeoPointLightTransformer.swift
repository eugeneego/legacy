// Generated using Sourcery 0.16.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct UserAddressGeoPointLightTransformer: LightTransformer {
    typealias T = User.Address.GeoPoint

    let latName = "lat"
    let lngName = "lng"

    let latTransformer = CastLightTransformer<String>()
    let lngTransformer = CastLightTransformer<String>()

    func from(any value: Any?) -> T? {
        guard let dictionary = value as? [String: Any] else { return nil }

        guard let lat = latTransformer.from(any: dictionary[latName]) else { return nil }
        guard let lng = lngTransformer.from(any: dictionary[lngName]) else { return nil }

        return T(
            lat: lat,
            lng: lng
        )
    }

    func to(any value: T?) -> Any? {
        guard let value = value else { return nil }

        var dictionary: [String: Any] = [:]
        dictionary[latName] = latTransformer.to(any: value.lat)
        dictionary[lngName] = lngTransformer.to(any: value.lng)
        return dictionary
    }
}
