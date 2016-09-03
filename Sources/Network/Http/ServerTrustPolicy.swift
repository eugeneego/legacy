//
// ServerTrustPolicy
// EE Utilities
//
// Copyright (c) 2014-2016 Alamofire Software Foundation (http://alamofire.org/)
// License: MIT, https://github.com/Alamofire/Alamofire/blob/master/LICENSE
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

public enum ServerTrustPolicy {
    case Default(checkHost: Bool)
    case Certificates(certificates: [SecCertificate], checkChain: Bool, checkHost: Bool)
    case PublicKeys(keys: [SecKey], checkChain: Bool, checkHost: Bool)
    case Disabled
    case Custom((serverTrust: SecTrust, host: String) -> Bool)

    public func evaluate(serverTrust serverTrust: SecTrust, host: String) -> Bool {
        switch self {
            case .Default(let checkHost):
                let policy = SecPolicyCreateSSL(true, checkHost ? host as CFString : nil)
                SecTrustSetPolicies(serverTrust, [ policy ])

                return trustIsValid(serverTrust)
            case .Certificates(let certificates, let checkChain, let checkHost):
                if checkChain {
                    let policy = SecPolicyCreateSSL(true, checkHost ? host as CFString : nil)
                    SecTrustSetPolicies(serverTrust, [ policy ])

                    SecTrustSetAnchorCertificates(serverTrust, certificates)
                    SecTrustSetAnchorCertificatesOnly(serverTrust, true)

                    return trustIsValid(serverTrust)
                } else {
                    let serverDataArray = dataForTrust(serverTrust)
                    let pinnedDataArray = dataForCertificates(certificates)

                    for serverData in serverDataArray {
                        for pinnedData in pinnedDataArray {
                            if serverData == pinnedData {
                                return true
                            }
                        }
                    }

                    return false
                }
            case .PublicKeys(let keys, let checkChain, let checkHost):
                if checkChain {
                    let policy = SecPolicyCreateSSL(true, checkHost ? host as CFString : nil)
                    SecTrustSetPolicies(serverTrust, [ policy ])

                    if !trustIsValid(serverTrust) {
                        return false
                    }
                }

                for serverKey in publicKeysForTrust(serverTrust) as [AnyObject] {
                    for key in keys as [AnyObject] {
                        if serverKey.isEqual(key) {
                            return true
                        }
                    }
                }

                return false
            case .Disabled:
                return true
            case let .Custom(closure):
                return closure(serverTrust: serverTrust, host: host)
        }
    }

    // MARK: - Routines

    private func trustIsValid(trust: SecTrust) -> Bool {
        var isValid = false

        var result = SecTrustResultType(kSecTrustResultInvalid)
        let status = SecTrustEvaluate(trust, &result)

        if status == errSecSuccess {
            let unspecified = SecTrustResultType(kSecTrustResultUnspecified)
            let proceed = SecTrustResultType(kSecTrustResultProceed)
            isValid = result == unspecified || result == proceed
        }

        return isValid
    }

    private func dataForTrust(trust: SecTrust) -> [NSData] {
        var certificates: [SecCertificate] = []

        for index in 0 ..< SecTrustGetCertificateCount(trust) {
            if let certificate = SecTrustGetCertificateAtIndex(trust, index) {
                certificates.append(certificate)
            }
        }

        return dataForCertificates(certificates)
    }

    private func dataForCertificates(certificates: [SecCertificate]) -> [NSData] {
        return certificates.map { SecCertificateCopyData($0) as NSData }
    }

    private func publicKeysForTrust(trust: SecTrust) -> [SecKey] {
        var keys: [SecKey] = []

        for index in 0 ..< SecTrustGetCertificateCount(trust) {
            if let cert = SecTrustGetCertificateAtIndex(trust, index), key = ServerTrustPolicy.publicKeyForCertificate(cert) {
                keys.append(key)
            }
        }

        return keys
    }

    private static func publicKeyForCertificate(certificate: SecCertificate) -> SecKey? {
        var key: SecKey?

        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)

        if let trust = trust where trustCreationStatus == errSecSuccess {
            key = SecTrustCopyPublicKey(trust)
        }

        return key
    }

    // MARK: - Loading

    public static func certificate(path path: String) -> SecCertificate? {
        return NSData(contentsOfFile: path).flatMap { SecCertificateCreateWithData(nil, $0) }
    }

    public static func certificate(url url: NSURL) -> SecCertificate? {
        return NSData(contentsOfURL: url).flatMap { SecCertificateCreateWithData(nil, $0) }
    }

    public static func publicKey(path path: String) -> SecKey? {
        return certificate(path: path).flatMap(publicKeyForCertificate)
    }

    public static func publicKey(url url: NSURL) -> SecKey? {
        return certificate(url: url).flatMap(publicKeyForCertificate)
    }
}
