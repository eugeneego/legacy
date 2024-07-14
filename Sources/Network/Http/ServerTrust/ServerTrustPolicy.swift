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

public enum ServerTrustPolicy: Sendable {
    case `default`(checkHost: Bool)
    case certificates(certificates: [SecCertificate], checkChain: Bool, checkHost: Bool)
    case publicKeys(keys: [SecKey], checkChain: Bool, checkHost: Bool)
    case hpkp(hashes: Set<Data>, algorithms: [Hpkp.PublicKeyAlgorithm], checkChain: Bool, checkHost: Bool)
    case custom(@Sendable (_ serverTrust: SecTrust, _ host: String) -> Bool)
    case disabled

    public func evaluate(serverTrust: SecTrust, host: String) async -> Bool {
        switch self {
        case .default(let checkHost):
            let policy = SecPolicyCreateSSL(true, checkHost ? host as CFString : nil)
            SecTrustSetPolicies(serverTrust, policy)
            return SecHelper.evaluate(trust: serverTrust)
        case .certificates(let certificates, let checkChain, let checkHost):
            if checkChain {
                let policy = SecPolicyCreateSSL(true, checkHost ? host as CFString : nil)
                SecTrustSetPolicies(serverTrust, policy)
                SecTrustSetAnchorCertificates(serverTrust, certificates as CFArray)
                SecTrustSetAnchorCertificatesOnly(serverTrust, true)
                return SecHelper.evaluate(trust: serverTrust)
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
                if !SecHelper.evaluate(trust: serverTrust) {
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
            return await Hpkp.check(
                serverTrust: serverTrust,
                host: host,
                hashes: hashes,
                algorithms: algorithms,
                checkChain: checkChain,
                checkHost: checkHost
            )
        case .custom(let closure):
            return closure(serverTrust, host)
        case .disabled:
            return true
        }
    }

    // MARK: - Routines

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
            if let cert = SecTrustGetCertificateAtIndex(trust, index), let key = SecHelper.publicKey(certificate: cert) {
                keys.append(key)
            }
        }
        return keys
    }
}

#if hasFeature(RetroactiveAttribute)
extension SecKey: @unchecked @retroactive Sendable {}
extension SecTrust: @unchecked @retroactive Sendable {}
extension SecCertificate: @unchecked @retroactive Sendable {}
#else
extension SecKey: @unchecked Sendable {}
extension SecTrust: @unchecked Sendable {}
extension SecCertificate: @unchecked Sendable {}
#endif
