//
// DeviceInfoTests
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if !os(watchOS)

import XCTest
@testable import Legacy

class DeviceInfoTests: XCTestCase {
    func testMain() {
        let deviceInfo = DeviceInfo.main

        XCTAssert(!deviceInfo.machineName.isEmpty)
        XCTAssert(!deviceInfo.machineDisplayName.isEmpty)
        XCTAssert(!deviceInfo.system.isEmpty)
        XCTAssert(!deviceInfo.systemVersion.isEmpty)
    }

    func testBundle() {
        let deviceInfo = DeviceInfo(bundle: Bundle(for: DeviceInfoTests.self))

        XCTAssert(!deviceInfo.machineName.isEmpty)
        XCTAssert(!deviceInfo.machineDisplayName.isEmpty)
        XCTAssert(!deviceInfo.system.isEmpty)
        XCTAssert(!deviceInfo.systemVersion.isEmpty)

        XCTAssert(!deviceInfo.bundleName.isEmpty)
        XCTAssert(!deviceInfo.bundleDisplayName.isEmpty)
        XCTAssert(!deviceInfo.bundleIdentifier.isEmpty)
        XCTAssert(!deviceInfo.bundleVersion.isEmpty)
        XCTAssert(!deviceInfo.bundleBuild.isEmpty)
    }

    func testClass() {
        let deviceInfo = DeviceInfo(class: Odin.self)

        XCTAssert(!deviceInfo.machineName.isEmpty)
        XCTAssert(!deviceInfo.machineDisplayName.isEmpty)
        XCTAssert(!deviceInfo.system.isEmpty)
        XCTAssert(!deviceInfo.systemVersion.isEmpty)

        XCTAssert(!deviceInfo.bundleName.isEmpty)
        XCTAssert(!deviceInfo.bundleDisplayName.isEmpty)
        XCTAssert(!deviceInfo.bundleIdentifier.isEmpty)
        XCTAssert(!deviceInfo.bundleVersion.isEmpty)
        XCTAssert(!deviceInfo.bundleBuild.isEmpty)
    }
}

#endif
