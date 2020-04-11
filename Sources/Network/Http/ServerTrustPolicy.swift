//
// ServerTrustPolicy
// Legacy
//
// Copyright (c) 2014-2016 Alamofire Software Foundation (http://alamofire.org/)
// License: MIT, https://github.com/Alamofire/Alamofire/blob/master/LICENSE
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation

public enum ServerTrustPolicy {
    case `default`(checkHost: Bool)
    case certificates(certificates: [SecCertificate], checkChain: Bool, checkHost: Bool)
    case publicKeys(keys: [SecKey], checkChain: Bool, checkHost: Bool)
    @available(iOS 10.0, *)
    @available(macOS 10.12, *)
    case hpkp(hashes: Set<Data>, algorithms: [Hpkp.PublicKeyAlgorithm], checkChain: Bool, checkHost: Bool)
    case custom((_ serverTrust: SecTrust, _ host: String) -> Bool)
    case disabled

    public func evaluate(serverTrust: SecTrust, host: String) -> Bool {
        switch self {
            case .default(let checkHost):
                let policy = SecPolicyCreateSSL(true, checkHost ? host as CFString : nil)
                SecTrustSetPolicies(serverTrust, policy)
                return trustIsValid(serverTrust)
            case .certificates(let certificates, let checkChain, let checkHost):
                if checkChain {
                    let policy = SecPolicyCreateSSL(true, checkHost ? host as CFString : nil)
                    SecTrustSetPolicies(serverTrust, policy)

                    SecTrustSetAnchorCertificates(serverTrust, certificates as CFArray)
                    SecTrustSetAnchorCertificatesOnly(serverTrust, true)

                    return trustIsValid(serverTrust)
                } else {
                    let serverDataArray = dataForTrust(serverTrust)
                    let pinnedDataArray = dataForCertificates(certificates)

                    for serverData in serverDataArray {
                        for pinnedData in pinnedDataArray where serverData == pinnedData {
                            return true
                        }
                    }

                    return false
                }
            case .publicKeys(let keys, let checkChain, let checkHost):
                if checkChain {
                    let policy = SecPolicyCreateSSL(true, checkHost ? host as CFString : nil)
                    SecTrustSetPolicies(serverTrust, policy)
                    if !trustIsValid(serverTrust) {
                        return false
                    }
                }

                for serverKey in publicKeysForTrust(serverTrust) as [AnyObject] {
                    for key in keys as [AnyObject] where serverKey.isEqual(key) {
                        return true
                    }
                }

                return false
            case .hpkp(let hashes, let algorithms, let checkChain, let checkHost):
                guard #available(iOS 10.0, macOS 10.12, *) else { return false }
                return Hpkp.check(serverTrust: serverTrust, host: host, hashes: hashes, algorithms: algorithms,
                    checkChain: checkChain, checkHost: checkHost)
            case let .custom(closure):
                return closure(serverTrust, host)
            case .disabled:
                return true
        }
    }

    // MARK: - Routines

    private func trustIsValid(_ trust: SecTrust) -> Bool {
        var isValid = false
        var result: SecTrustResultType = .invalid
        if SecTrustEvaluate(trust, &result) == errSecSuccess {
            isValid = result == .unspecified || result == .proceed
        }
        return isValid
    }

    private func dataForTrust(_ trust: SecTrust) -> [Data] {
        var certificates: [SecCertificate] = []
        for index in 0 ..< SecTrustGetCertificateCount(trust) {
            if let certificate = SecTrustGetCertificateAtIndex(trust, index) {
                certificates.append(certificate)
            }
        }
        return dataForCertificates(certificates)
    }

    private func dataForCertificates(_ certificates: [SecCertificate]) -> [Data] {
        certificates.map { SecCertificateCopyData($0) as Data }
    }

    private func publicKeysForTrust(_ trust: SecTrust) -> [SecKey] {
        var keys: [SecKey] = []
        for index in 0 ..< SecTrustGetCertificateCount(trust) {
            if let cert = SecTrustGetCertificateAtIndex(trust, index), let key = ServerTrustPolicy.publicKeyForCertificate(cert) {
                keys.append(key)
            }
        }
        return keys
    }

    private static func publicKeyForCertificate(_ certificate: SecCertificate) -> SecKey? {
        var key: SecKey?

        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)

        if let trust = trust, trustCreationStatus == errSecSuccess {
            key = SecTrustCopyPublicKey(trust)
        }

        return key
    }

    // MARK: - Loading

    public static func certificate(path: String) -> SecCertificate? {
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        return data.flatMap { SecCertificateCreateWithData(nil, $0 as CFData) }
    }

    public static func certificate(url: URL) -> SecCertificate? {
        let data = try? Data(contentsOf: url)
        return data.flatMap { SecCertificateCreateWithData(nil, $0 as CFData) }
    }

    public static func publicKey(path: String) -> SecKey? {
        certificate(path: path).flatMap(publicKeyForCertificate)
    }

    public static func publicKey(url: URL) -> SecKey? {
        certificate(url: url).flatMap(publicKeyForCertificate)
    }
}
