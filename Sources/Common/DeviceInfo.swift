//
// DeviceInfo
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif

/// Device and application information.
public struct DeviceInfo: CustomStringConvertible {
    /// Static instance with device and application information.
    /// - note:
    /// Application information is extracted from the main bundle.
    @MainActor
    public static let main: DeviceInfo = DeviceInfo(bundle: Bundle.main)

    /// Machine name. Example: `iPhone10,6`
    public let machineName: String

    /// Machine display name. Example: `iPhone X (GSM, LTE)`
    public let machineDisplayName: String

    /// Operating system name. Example `iOS`
    public let system: String

    /// Operating system version. Example `11.2`
    public let systemVersion: String

    /// Application bundle name. Example: `MyApp`
    /// - **Info.plist**: CFBundleName
    public let bundleName: String

    /// Application bundle display name. Example: `MyApp`
    /// - **Xcode**: Target settings -> General -> Identity -> Display Name
    /// - **Info.plist**: CFBundleDisplayName or CFBundleName
    public let bundleDisplayName: String

    /// Application bundle identifier. Example: `com.company.app`
    /// - **Xcode**: Target settings -> General -> Identity -> Bundle Identifier
    /// - **Info.plist**: CFBundleIdentifier
    public let bundleIdentifier: String

    /// Application bundle version. Example: `3.14`
    /// - **Xcode**: Target settings -> General -> Identity -> Version
    /// - **Info.plist**: CFBundleShortVersionString
    public let bundleVersion: String

    /// Application bundle build. Example: `159`
    /// - **Xcode**: Target settings -> General -> Identity -> Build
    /// - **Info.plist**: CFBundleVersion
    public let bundleBuild: String

    /// An alphanumeric string that uniquely identifies a device to the app’s vendor. Example: `EA7583CD-A667-48BC-B806-42ECB2B48606`
    public let identifierForVendor: UUID?

    /// Initializes with a bundle with a reference class.
    @MainActor
    public init(class: AnyClass) {
        self.init(bundle: Bundle(for: `class`))
    }

    /// Initializes with a bundle.
    @MainActor
    public init(bundle: Bundle) {
        let processInfo = ProcessInfo.processInfo

        let version = processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion)\(version.patchVersion == 0 ? "" : ".\(version.patchVersion)")"

        #if os(iOS) || os(tvOS)
        let device = UIDevice.current
        if #available(iOS 14.0, tvOS 14.0, *), processInfo.isiOSAppOnMac {
            system = "\(device.systemName) (macOS, Native)"
            systemVersion = "\(device.systemVersion) / \(versionString)"
            machineName = Self.product
        } else if #available(iOS 13.0, tvOS 13.0, *), processInfo.isMacCatalystApp {
            system = "\(device.systemName) (macOS, Catalyst)"
            systemVersion = "\(device.systemVersion) (\(versionString))"
            machineName = Self.product
        } else {
            system = device.systemName
            systemVersion = device.systemVersion
            machineName = Self.machine
        }
        identifierForVendor = device.identifierForVendor
        #elseif os(watchOS)
        let device = WKInterfaceDevice.current()
        system = device.systemName
        systemVersion = device.systemVersion
        if #available(watchOS 6.2, *) {
            identifierForVendor = device.identifierForVendor
        } else {
            identifierForVendor = nil
        }
        machineName = Self.machine
        #elseif os(macOS)
        system = "macOS"
        systemVersion = versionString
        identifierForVendor = nil
        machineName = Self.product
        #endif

        let localName = machineName
        machineDisplayName = Self.machineDisplayNames[machineName] ?? localName

        let localBundleName = bundle.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? ""
        bundleName = localBundleName
        bundleDisplayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName" as String) as? String ?? localBundleName
        bundleIdentifier = bundle.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String ?? ""
        bundleVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        bundleBuild = bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
    }

    public var description: String {
        """
        DeviceInfo:
            machineName: \(machineName)
            machineDisplayName: \(machineDisplayName)
            system: \(system)
            systemVersion: \(systemVersion)
            bundleName: \(bundleName)
            bundleDisplayName: \(bundleDisplayName)
            bundleIdentifier: \(bundleIdentifier)
            bundleVersion: \(bundleVersion)
            bundleBuild: \(bundleBuild)
        """
    }

    private static var product: String {
        sysctlString(keys: [ CTL_HW, HW_PRODUCT ])
    }

    private static var machine: String {
        sysctlString(keys: [ CTL_HW, HW_MACHINE ])
    }

    private static var model: String {
        sysctlString(keys: [ CTL_HW, HW_MODEL ])
    }

    private static var target: String {
        sysctlString(keys: [ CTL_HW, HW_TARGET ])
    }

    private static func sysctlString(keys: [Int32]) -> String {
        var keys = keys
        var size: Int = 0
        sysctl(&keys, u_int(keys.count), nil, &size, nil, 0)
        var value: [CChar] = Array(repeating: 0, count: size)
        sysctl(&keys, 2, &value, &size, nil, 0)
        return String(cString: value)
    }

    private static let machineDisplayNames: [String: String] = [
        "i386": "iOS Simulator (x86)",
        "x86_64": "iOS Simulator (x86_64)",
        "arm64": "iOS Simulator (ARM)",

        "iPhone1,1": "iPhone",
        "iPhone1,2": "iPhone 3G",
        "iPhone2,1": "iPhone 3GS",
        "iPhone3,1": "iPhone 4 (GSM)",
        "iPhone3,2": "iPhone 4 (GSM Rev A)",
        "iPhone3,3": "iPhone 4 (CDMA)",
        "iPhone4,1": "iPhone 4S",
        "iPhone5,1": "iPhone 5 (GSM, LTE)",
        "iPhone5,2": "iPhone 5 (GSM, CDMA, LTE)",
        "iPhone5,3": "iPhone 5C (GSM, CDMA, LTE)",
        "iPhone5,4": "iPhone 5C (GSM, LTE)",
        "iPhone6,1": "iPhone 5S (GSM, CDMA, LTE)",
        "iPhone6,2": "iPhone 5S (GSM, LTE)",
        "iPhone7,1": "iPhone 6 Plus",
        "iPhone7,2": "iPhone 6",
        "iPhone8,1": "iPhone 6s",
        "iPhone8,2": "iPhone 6s Plus",
        "iPhone8,3": "iPhone SE (GSM, CDMA, LTE)",
        "iPhone8,4": "iPhone SE (GSM, LTE)",
        "iPhone9,1": "iPhone 7 (GSM, CDMA, LTE)",
        "iPhone9,2": "iPhone 7 Plus (GSM, CDMA, LTE)",
        "iPhone9,3": "iPhone 7 (GSM, LTE)",
        "iPhone9,4": "iPhone 7 Plus (GSM, LTE)",
        "iPhone10,1": "iPhone 8 (GSM, CDMA, LTE)",
        "iPhone10,2": "iPhone 8 Plus (GSM, CDMA, LTE)",
        "iPhone10,3": "iPhone X (GSM, CDMA, LTE)",
        "iPhone10,4": "iPhone 8 (GSM, LTE)",
        "iPhone10,5": "iPhone 8 Plus (GSM, LTE)",
        "iPhone10,6": "iPhone X (GSM, LTE)",
        "iPhone11,2": "iPhone XS",
        "iPhone11,4": "iPhone XS Max (China)",
        "iPhone11,6": "iPhone XS Max",
        "iPhone11,8": "iPhone XR",
        "iPhone12,1": "iPhone 11",
        "iPhone12,3": "iPhone 11 Pro",
        "iPhone12,5": "iPhone 11 Pro Max",
        "iPhone12,8": "iPhone SE (2nd Gen)",
        "iPhone13,1": "iPhone 12 Mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,4": "iPhone 13 Mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,6": "iPhone SE (3rd Gen)",
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",

        "iPad1,1": "iPad",
        "iPad2,1": "iPad 2 (Wi-Fi)",
        "iPad2,2": "iPad 2 (Wi-Fi, GSM)",
        "iPad2,3": "iPad 2 (Wi-Fi, CDMA)",
        "iPad2,4": "iPad 2 (Wi-Fi, New Revision)",
        "iPad2,5": "iPad mini (Wi-Fi)",
        "iPad2,6": "iPad mini (Wi-Fi, GSM, LTE)",
        "iPad2,7": "iPad mini (Wi-Fi, GSM, CDMA, LTE)",
        "iPad3,1": "iPad 3 (Wi-Fi)",
        "iPad3,2": "iPad 3 (Wi-Fi, GSM, CDMA, LTE)",
        "iPad3,3": "iPad 3 (Wi-Fi, GSM, LTE)",
        "iPad3,4": "iPad 4 (Wi-Fi)",
        "iPad3,5": "iPad 4 (Wi-Fi, GSM, LTE)",
        "iPad3,6": "iPad 4 (Wi-Fi, GSM, CDMA, LTE)",
        "iPad4,1": "iPad Air (Wi-Fi)",
        "iPad4,2": "iPad Air (Wi-Fi, Cellular)",
        "iPad4,3": "iPad Air (Wi-Fi, Cellular, China)",
        "iPad4,4": "iPad mini 2 (Wi-Fi)",
        "iPad4,5": "iPad mini 2 (Wi-Fi, Cellular)",
        "iPad4,6": "iPad mini 2 (Wi-Fi, Cellular, China)",
        "iPad4,7": "iPad mini 3 (Wi-Fi)",
        "iPad4,8": "iPad mini 3 (Wi-Fi, Cellular)",
        "iPad4,9": "iPad mini 3 (Wi-Fi, Cellular, China)",
        "iPad5,1": "iPad mini 4 (Wi-Fi)",
        "iPad5,2": "iPad mini 4 (Wi-Fi, Cellular)",
        "iPad5,3": "iPad Air 2 (Wi-Fi)",
        "iPad5,4": "iPad Air 2 (Wi-Fi, Cellular)",
        "iPad5,5": "iPad Air 2 (Wi-Fi, Cellular, China)",
        "iPad6,3": "iPad Pro (9.7\", Wi-Fi)",
        "iPad6,4": "iPad Pro (9.7\", Wi-Fi, Cellular)",
        "iPad6,7": "iPad Pro (12.9\", Wi-Fi)",
        "iPad6,8": "iPad Pro (12.9\", Wi-Fi, Cellular)",
        "iPad6,11": "iPad (5th Gen, Wi-Fi)",
        "iPad6,12": "iPad (5th Gen, Wi-Fi, Cellular)",
        "iPad7,1": "iPad Pro (12.9\", 2nd Gen, Wi-Fi)",
        "iPad7,2": "iPad Pro (12.9\", 2nd Gen, Wi-Fi, Cellular)",
        "iPad7,3": "iPad Pro (10.5\", Wi-Fi)",
        "iPad7,4": "iPad Pro (10.5\", Wi-Fi, Cellular)",
        "iPad7,5": "iPad (6th Gen, Wi-Fi)",
        "iPad7,6": "iPad (6th Gen, Wi-Fi, Cellular)",
        "iPad7,11": "iPad (10.2\", 7th Gen, Wi-Fi)",
        "iPad7,12": "iPad (10.2\", 7th Gen, Wi-Fi, Cellular)",
        "iPad8,1": "iPad Pro (11\", Wi-Fi)",
        "iPad8,2": "iPad Pro (11\", 1TB, Wi-Fi)",
        "iPad8,3": "iPad Pro (11\", Wi-Fi, Cellular)",
        "iPad8,4": "iPad Pro (11\", 1TB, Wi-Fi, Cellular)",
        "iPad8,5": "iPad Pro (12.9\", 3rd Gen, Wi-Fi)",
        "iPad8,6": "iPad Pro (12.9\", 3rd Gen, 1TB, Wi-Fi)",
        "iPad8,7": "iPad Pro (12.9\", 3rd Gen, Wi-Fi, Cellular)",
        "iPad8,8": "iPad Pro (12.9\", 3rd Gen, 1TB, Wi-Fi, Cellular)",
        "iPad8,9": "iPad Pro (11\", 2nd Gen, Wi-Fi)",
        "iPad8,10": "iPad Pro (11\", 2nd Gen, Wi-Fi, Cellular)",
        "iPad8,11": "iPad Pro (12.9\", 4th Gen, Wi-Fi)",
        "iPad8,12": "iPad Pro (12.9\", 4th Gen, Wi-Fi, Cellular)",
        "iPad11,1": "iPad mini 5 (Wi-Fi)",
        "iPad11,2": "iPad mini 5 (Wi-Fi, Cellular)",
        "iPad11,3": "iPad Air 3 (Wi-Fi)",
        "iPad11,4": "iPad Air 3 (Wi-Fi, Cellular)",
        "iPad11,6": "iPad (10.2\", 8th Gen, Wi-Fi)",
        "iPad11,7": "iPad (10.2\", 8th Gen, Wi-Fi, Cellular)",
        "iPad12,1": "iPad (10.2\", 9th Gen, Wi-Fi)",
        "iPad12,2": "iPad (10.2\", 9th Gen, Wi-Fi, Cellular)",
        "iPad13,1": "iPad Air 4 (Wi-Fi)",
        "iPad13,2": "iPad Air 4 (Wi-Fi, Cellular)",
        "iPad13,4": "iPad Pro (11\", 3rd Gen, Wi-Fi)",
        "iPad13,5": "iPad Pro (11\", 3rd Gen, Wi-Fi, Cellular, US)",
        "iPad13,6": "iPad Pro (11\", 3rd Gen, Wi-Fi, Cellular, Global)",
        "iPad13,7": "iPad Pro (11\", 3rd Gen, Wi-Fi, Cellular, China)",
        "iPad13,8": "iPad Pro (12.9\", 5th Gen, Wi-Fi)",
        "iPad13,9": "iPad Pro (12.9\", 5th Gen, Wi-Fi, Cellular, US)",
        "iPad13,10": "iPad Pro (12.9\", 5th Gen, Wi-Fi, Cellular, Global)",
        "iPad13,11": "iPad Pro (12.9\", 5th Gen, Wi-Fi, Cellular, China)",
        "iPad13,16": "iPad (Air, 5th Gen, Wi-Fi)",
        "iPad13,17": "iPad (Air, 5th Gen, Wi-Fi, Cellular)",
        "iPad13,18": "iPad (10.9\", 10th Gen, Wi-Fi)",
        "iPad13,19": "iPad (10.9\", 10th Gen, Wi-Fi, Cellular)",
        "iPad14,1": "iPad mini 6 (Wi-Fi)",
        "iPad14,2": "iPad mini 6 (Wi-Fi, Cellular)",
        "iPad14,3": "iPad Pro (11\", 4th Gen, Wi-Fi)",
        "iPad14,4": "iPad Pro (11\", 4th Gen, Wi-Fi, Cellular)",
        "iPad14,5": "iPad Pro (12.9\", 6th Gen, Wi-Fi)",
        "iPad14,6": "iPad Pro (12.9\", 6th Gen, Wi-Fi, Cellular)",
        "iPad14,8": "iPad Air (11\", 6th Gen, M2, Wi-Fi)",
        "iPad14,9": "iPad Air (11\", 6th Gen, M2, Wi-Fi, Cellular)",
        "iPad14,10": "iPad Air (13\", 6th Gen, M2, Wi-Fi)",
        "iPad14,11": "iPad Air (13\", 6th Gen, M2, Wi-Fi, Cellular)",
        "iPad16,3": "iPad Pro (11\", 5th Gen, M4, Wi-Fi)",
        "iPad16,4": "iPad Pro (11\", 5th Gen, M4, Wi-Fi, Cellular)",
        "iPad16,5": "iPad Pro (13\", 7th Gen, M4, Wi-Fi)",
        "iPad16,6": "iPad Pro (13\", 7th Gen, M4, Wi-Fi, Cellular)",

        "iPod1,1": "iPod Touch",
        "iPod2,1": "iPod Touch (2nd Generation)",
        "iPod3,1": "iPod Touch (3rd Generation)",
        "iPod4,1": "iPod Touch (4th Generation)",
        "iPod5,1": "iPod Touch (5th Generation)",
        "iPod7,1": "iPod Touch (6th Generation)",
        "iPod9,1": "iPod Touch (7th Generation)",

        "Watch1,1": "Apple Watch (38mm)",
        "Watch1,2": "Apple Watch (42mm)",
        "Watch2,3": "Apple Watch Series 2 (38mm)",
        "Watch2,4": "Apple Watch Series 2 (42mm)",
        "Watch2,6": "Apple Watch Series 1 (38mm)",
        "Watch2,7": "Apple Watch Series 1 (42mm)",
        "Watch3,1": "Apple Watch Series 3 (38mm, Cellular)",
        "Watch3,2": "Apple Watch Series 3 (42mm, Cellular)",
        "Watch3,3": "Apple Watch Series 3 (38mm, GPS)",
        "Watch3,4": "Apple Watch Series 3 (42mm, GPS)",
        "Watch4,1": "Apple Watch Series 4 (40mm, GPS)",
        "Watch4,2": "Apple Watch Series 4 (44mm, GPS)",
        "Watch4,3": "Apple Watch Series 4 (40mm, GPS, Cellular)",
        "Watch4,4": "Apple Watch Series 4 (44mm, GPS, Cellular)",
        "Watch5,1": "Apple Watch Series 5 (40mm, GPS)",
        "Watch5,2": "Apple Watch Series 5 (44mm, GPS)",
        "Watch5,3": "Apple Watch Series 5 (40mm, GPS, Cellular)",
        "Watch5,4": "Apple Watch Series 5 (44mm, GPS, Cellular)",
        "Watch5,9": "Apple Watch SE (40mm, GPS)",
        "Watch5,10": "Apple Watch SE (44mm, GPS)",
        "Watch5,11": "Apple Watch SE (40mm, GPS, Cellular)",
        "Watch5,12": "Apple Watch SE (44mm, GPS, Cellular)",
        "Watch6,1": "Apple Watch Series 6 (40mm, GPS)",
        "Watch6,2": "Apple Watch Series 6 (44mm, GPS)",
        "Watch6,3": "Apple Watch Series 6 (40mm, GPS, Cellular)",
        "Watch6,4": "Apple Watch Series 6 (44mm, GPS, Cellular)",
        "Watch6,6": "Apple Watch Series 7 (41mm, GPS)",
        "Watch6,7": "Apple Watch Series 7 (45mm, GPS)",
        "Watch6,8": "Apple Watch Series 7 (41mm, GPS, Cellular)",
        "Watch6,9": "Apple Watch Series 7 (45mm, GPS, Cellular)",
        "Watch6,10": "Apple Watch SE 2 (40mm, GPS)",
        "Watch6,11": "Apple Watch SE 2 (44mm, GPS)",
        "Watch6,12": "Apple Watch SE 2 (40mm, GPS, Cellular)",
        "Watch6,13": "Apple Watch SE 2 (44mm, GPS, Cellular)",
        "Watch6,14": "Apple Watch Series 8 (41mm, GPS)",
        "Watch6,15": "Apple Watch Series 8 (45mm, GPS)",
        "Watch6,16": "Apple Watch Series 8 (41mm, GPS, Cellular)",
        "Watch6,17": "Apple Watch Series 8 (45mm, GPS, Cellular)",
        "Watch6,18": "Apple Watch Ultra",
        "Watch7,1": "Apple Watch Series 9 (41mm, GPS)",
        "Watch7,2": "Apple Watch Series 9 (45mm, GPS)",
        "Watch7,3": "Apple Watch Series 9 (41mm, GPS, Cellular)",
        "Watch7,4": "Apple Watch Series 9 (45mm, GPS, Cellular)",
        "Watch7,5": "Apple Watch Ultra 2",

        "AppleTV5,3": "Apple TV (4th Gen)",
        "AppleTV6,2": "Apple TV 4K",
        "AppleTV11,1": "Apple TV 4K (2nd Gen)",
        "AppleTV14,1": "Apple TV 4K (3rd Gen)",
    ]
}
