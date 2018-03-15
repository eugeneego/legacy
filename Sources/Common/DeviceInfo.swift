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
#endif

public class DeviceInfo {
    public static let instance: DeviceInfo = DeviceInfo()

    public let machineName: String
    public let machineDisplayName: String

    public let system: String
    public let systemVersion: String

    public let bundleIdentifier: String
    public let bundleVersion: String
    public let bundleBuild: String

    private init() {
        let bundle = Bundle.main
        #if os(iOS)
        let device = UIDevice.current
        #elseif os(watchOS)
        let device = WKInterfaceDevice.current()
        #endif

        let name = DeviceInfo.getMachineName()
        machineName = name
        machineDisplayName = DeviceInfo.machineDisplayNames[machineName] ?? name

        system = device.systemName
        systemVersion = device.systemVersion

        bundleIdentifier = bundle.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String ?? ""
        bundleVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        bundleBuild = bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
    }

    private static func getMachineName() -> String {
        var name: [Int32] = [ CTL_HW, HW_MACHINE ]
        var size: Int = 2
        sysctl(&name, 2, nil, &size, nil, 0)
        var hw_machine: [CChar] = Array(repeating: 0, count: size)
        sysctl(&name, 2, &hw_machine, &size, nil, 0)
        return String(cString: hw_machine)
    }

    private static let machineDisplayNames: [String: String] = [
        "i386": "iOS Simulator",
        "x86_64": "iOS Simulator (x64)",

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
        "iPad5,3": "iPad Air 2 (Wi-Fi)",
        "iPad5,4": "iPad Air 2 (Wi-Fi, Cellular)",
        "iPad5,5": "iPad Air 2 (Wi-Fi, Cellular, China)",
        "iPad6,3": "iPad Pro (9.7, Wi-Fi)",
        "iPad6,4": "iPad Pro (9.7, Wi-Fi, Cellular)",
        "iPad6,7": "iPad Pro (12.9, Wi-Fi)",
        "iPad6,8": "iPad Pro (12.9, Wi-Fi, Cellular)",
        "iPad6,11": "iPad (2017, Wi-Fi)",
        "iPad6,12": "iPad (2017, Wi-Fi, Cellular)",
        "iPad7,1": "iPad Pro (12.9, 2nd Generation, Wi-Fi)",
        "iPad7,2": "iPad Pro (12.9, 2nd Generation, Wi-Fi, Cellular)",
        "iPad7,3": "iPad Pro (10.5, Wi-Fi)",
        "iPad7,4": "iPad Pro (10.5, Wi-Fi, Cellular)",

        "iPod1,1": "iPod Touch",
        "iPod2,1": "iPod Touch (2nd Generation)",
        "iPod3,1": "iPod Touch (3rd Generation)",
        "iPod4,1": "iPod Touch (4th Generation)",
        "iPod5,1": "iPod Touch (5th Generation)",
        "iPod7,1": "iPod Touch (6th Generation)",

        "Watch1,1": "Apple Watch (38mm)",
        "Watch1,2": "Apple Watch (42mm)",
        "Watch2,3": "Apple Watch Series 2 (38mm)",
        "Watch2,4": "Apple Watch Series 2 (42mm)",
        "Watch2,6": "Apple Watch Series 1 (38mm)",
        "Watch2,7": "Apple Watch Series 1 (42mm)",
        "Watch3,3": "Apple Watch Series 3 (38mm, Cellular)",
        "Watch3,4": "Apple Watch Series 3 (42mm, Cellular)",
        "Watch3,3": "Apple Watch Series 3 (38mm, GPS)",
        "Watch3,4": "Apple Watch Series 3 (42mm, GPS)",

        "AppleTV5,3": "Apple TV (4th Generation)",
        "AppleTV6,2": "Apple TV 4K",
    ]
}
