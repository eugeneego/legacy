//
// SecHelper
// Legacy
//
// Copyright (c) 2021 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public enum SecHelper {
    public static func evaluate(trust: SecTrust) -> Bool {
        var isValid = false
        if #available(iOS 12.0, tvOS 12.0, watchOS 5.0, macOS 10.14, *) {
            isValid = SecTrustEvaluateWithError(trust, nil)
        } else {
            var result: SecTrustResultType = .invalid
            if SecTrustEvaluate(trust, &result) == errSecSuccess {
                isValid = result == .unspecified || result == .proceed
            }
        }
        return isValid
    }

    public static func publicKey(certificate: SecCertificate) -> SecKey? {
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let status = SecTrustCreateWithCertificates(certificate, policy, &trust)

        guard status == errSecSuccess, let trust = trust else { return nil }

        let key = SecTrustCopyPublicKey(trust)
        return key
    }

    public static func certificate(path: String) -> SecCertificate? {
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        return data.flatMap { SecCertificateCreateWithData(nil, $0 as CFData) }
    }

    public static func certificate(url: URL) -> SecCertificate? {
        let data = try? Data(contentsOf: url)
        return data.flatMap { SecCertificateCreateWithData(nil, $0 as CFData) }
    }

    public static func publicKey(path: String) -> SecKey? {
        certificate(path: path).flatMap(publicKey(certificate:))
    }

    public static func publicKey(url: URL) -> SecKey? {
        certificate(url: url).flatMap(publicKey(certificate:))
    }
}
