//
// Hpkp
// Legacy
//
// HPKP hashes generation based on TrustKit, https://github.com/datatheorem/TrustKit
// Copyright 2015 The TrustKit Project Authors
// TrustKit is released under the MIT license.
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation
import CommonCrypto

@available(iOS 10.0, *)
@available(macOS 10.12, *)
@available(watchOS 3.0, *)
public class Hpkp {
    public enum PublicKeyAlgorithm {
        case rsa2048
        case rsa4096
        case ecDsaSecp256r1
        case ecDsaSecp384r1
    }

    public static func check(
        serverTrust: SecTrust,
        host: String,
        hashes: Set<Data>,
        algorithms: [PublicKeyAlgorithm],
        checkChain: Bool,
        checkHost: Bool
    ) -> Bool {
        let result = verifyPublicKeys(serverTrust: serverTrust, host: host, algorithms: algorithms,
            hashes: hashes, hashCache: Cache.instance, checkChain: checkChain, checkHost: checkHost)
        return result == .success
    }

    public static func hashes(_ hashes: [String]) -> Set<Data> {
        Set(hashes.compactMap { Data(base64Encoded: $0) })
    }

    private class Cache {
        private let lockQueue: DispatchQueue = DispatchQueue(label: "HPKPCache")
        private var hashes: [PublicKeyAlgorithm: [Data: Data]] = [:]

        static let instance: Cache = Cache()

        private init() {}

        func hashPublicKey(certificate: SecCertificate, algorithm: PublicKeyAlgorithm) -> Data? {
            let certificateData = SecCertificateCopyData(certificate) as Data

            var cachedHash: Data?
            lockQueue.sync {
                cachedHash = hashes[algorithm]?[certificateData]
            }

            if let cachedHash = cachedHash {
                return cachedHash
            }

            let hash = Hpkp.hashPublicKey(certificate: certificate, publicKeyAlgorithm: algorithm)

            lockQueue.sync {
                hashes[algorithm, default: [:]][certificateData] = hash
            }

            return hash
        }
    }

    private static func trustIsValid(_ trust: SecTrust) -> Bool {
        var isValid = false
        var result: SecTrustResultType = .invalid
        if SecTrustEvaluate(trust, &result) == errSecSuccess {
            isValid = result == .unspecified || result == .proceed
        }
        return isValid
    }

    private enum Result {
        case success
        case noMatchingPin
        case invalidCertificateChain
        case couldNotGenerateSpkiHash
    }

    private static func verifyPublicKeys(
        serverTrust: SecTrust,
        host: String,
        algorithms: [PublicKeyAlgorithm],
        hashes: Set<Data>,
        hashCache: Cache,
        checkChain: Bool,
        checkHost: Bool
    ) -> Result {
        if checkChain {
            let sslPolicy = SecPolicyCreateSSL(true, checkHost ? host as CFString : nil)
            SecTrustSetPolicies(serverTrust, sslPolicy)

            if !trustIsValid(serverTrust) {
                return .invalidCertificateChain
            }
        }

        let certificateChainLen = SecTrustGetCertificateCount(serverTrust)
        for index in 0 ..< certificateChainLen {
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, index) else {
                continue
            }

            for savedAlgorithm in algorithms {
                guard let hash = hashCache.hashPublicKey(certificate: certificate, algorithm: savedAlgorithm) else {
                    return .couldNotGenerateSpkiHash
                }

                if hashes.contains(hash) {
                    return .success
                }
            }
        }

        return .noMatchingPin
    }

    private static func publicKeyData(certificate: SecCertificate) -> Data? {
        var createdTrust: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        SecTrustCreateWithCertificates(certificate, policy, &createdTrust)

        guard let trust = createdTrust else { return nil }

        var result: SecTrustResultType = .invalid
        SecTrustEvaluate(trust, &result)
        guard let publicKey = SecTrustCopyPublicKey(trust) else { return nil }

        let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data?
        return publicKeyData
    }

    // Hash Calculation

    // These are the ASN1 headers for the Subject Public Key Info section of a certificate

    private static let rsa2048Asn1Header: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]

    private static let rsa4096Asn1Header: [UInt8] = [
        0x30, 0x82, 0x02, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x02, 0x0f, 0x00
    ]

    private static let ecDsaSecp256r1Asn1Header: [UInt8] = [
        0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
        0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03,
        0x42, 0x00
    ]

    private static let ecDsaSecp384r1Asn1Header: [UInt8] = [
        0x30, 0x76, 0x30, 0x10, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
        0x01, 0x06, 0x05, 0x2b, 0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00
    ]

    private static func asn1HeaderBytes(for publicKeyAlgorithm: PublicKeyAlgorithm) -> [UInt8] {
        switch publicKeyAlgorithm {
            case .rsa2048: return rsa2048Asn1Header
            case .rsa4096: return rsa4096Asn1Header
            case .ecDsaSecp256r1: return ecDsaSecp256r1Asn1Header
            case .ecDsaSecp384r1: return ecDsaSecp384r1Asn1Header
        }
    }

    private static func hashPublicKey(certificate: SecCertificate, publicKeyAlgorithm: PublicKeyAlgorithm) -> Data? {
        guard let publicKeyData = publicKeyData(certificate: certificate) else {
            return nil
        }

        let context = UnsafeMutablePointer<CC_SHA256_CTX>.allocate(capacity: 1)
        CC_SHA256_Init(context)

        let asn1Header = asn1HeaderBytes(for: publicKeyAlgorithm)
        _ = CC_SHA256_Update(context, asn1Header, CC_LONG(asn1Header.count))

        publicKeyData.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Void in
            if let base = bytes.baseAddress {
                _ = CC_SHA256_Update(context, base, CC_LONG(bytes.count))
            }
        }

        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256_Final(&digest, context)
        return Data(digest)
    }
}
