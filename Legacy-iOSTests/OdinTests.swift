//
// OdinTests
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if !os(watchOS)

import XCTest
@testable import Legacy

private protocol Test: AnyObject {
}

private protocol TestDependency {
    var test: Test! { get set }
}

private class TestObject: Test {
}

private class TestDependencyObject: TestDependency {
    var test: Test!
}

class OdinTests: XCTestCase {
    func testTypes() {
        let container = Odin()
        let testObject = TestObject()
        container.register { () -> Test in testObject }

        let resolvedTestObject: Test? = container.resolve()
        XCTAssert(resolvedTestObject === testObject)
    }

    func testTypesParent() {
        let parentContainer = Odin()
        let parentTestObject = TestObject()
        parentContainer.register { () -> Test in parentTestObject }

        let container = Odin(parentContainer: parentContainer)

        let resolvedParentTestObject: Test? = container.resolve()
        XCTAssert(resolvedParentTestObject === parentTestObject)
    }

    func testTypesParentOverride() {
        let parentContainer = Odin()
        let parentTestObject = TestObject()
        parentContainer.register { () -> Test in parentTestObject }

        let container = Odin(parentContainer: parentContainer)
        let testObject = TestObject()
        container.register { () -> Test in testObject }

        let resolvedTestObject: Test? = container.resolve()
        XCTAssert(resolvedTestObject === testObject)
    }

    func testProtocols() {
        let container = Odin()
        let testObject = TestObject()
        container.register { (object: inout TestDependency) in object.test = testObject }

        let testDependencyObject = TestDependencyObject()

        container.resolve(testDependencyObject)
        let resolvedTestObject = testDependencyObject.test
        XCTAssert(resolvedTestObject === testObject)
    }

    func testProtocolsParent() {
        let parentContainer = Odin()
        let parentTestObject = TestObject()
        parentContainer.register { (object: inout TestDependency) in object.test = parentTestObject }

        let container = Odin(parentContainer: parentContainer)

        let testDependencyObject = TestDependencyObject()

        container.resolve(testDependencyObject)
        let resolvedTestObject = testDependencyObject.test
        XCTAssert(resolvedTestObject === parentTestObject)
    }

    func testProtocolsParentOverride() {
        let parentContainer = Odin()
        let parentTestObject = TestObject()
        parentContainer.register { (object: inout TestDependency) in object.test = parentTestObject }

        let container = Odin(parentContainer: parentContainer)
        let testObject = TestObject()
        container.register { (object: inout TestDependency) in object.test = testObject }

        let testDependencyObject = TestDependencyObject()
        container.resolve(testDependencyObject)
        let resolvedTestObject = testDependencyObject.test
        XCTAssert(resolvedTestObject === testObject)
    }
}

#endif
