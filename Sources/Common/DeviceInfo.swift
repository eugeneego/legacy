//
// DeviceInfo
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

public class DeviceInfo {
    public static let instance: DeviceInfo = DeviceInfo()

    public let machineName: String

    public let system: String
    public let systemVersion: String

    public let bundleIdentifier: String
    public let bundleVersion: String
    public let bundleBuild: String

    private init() {
        let mainBundle = Bundle.main
        let device = UIDevice.current

        machineName = DeviceInfo.getMachineName()

        system = device.systemName
        systemVersion = device.systemVersion

        bundleIdentifier = mainBundle.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String ?? ""
        bundleVersion = mainBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        bundleBuild = mainBundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
    }

    private static func getMachineName() -> String {
        var name = [ CTL_HW, HW_MACHINE ]
        var size = 2
        sysctl(&name, 2, nil, &size, nil, 0)
        var hw_machine = [CChar](repeating: 0, count: size)
        sysctl(&name, 2, &hw_machine, &size, nil, 0)
        return String(cString: hw_machine)
    }
}
