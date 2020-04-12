//
// EETestCase
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if !os(watchOS)

import Foundation
import XCTest
@testable import Legacy

extension XCTestCase {
    typealias ExpectationHandler = (_ desctiption: String, _ expectation: XCTestExpectation) -> Void

    /// Asynchronous expectation helper.
    func expect(
        _ description: String,
        timeout: TimeInterval = 15,
        file: StaticString = #file,
        line: UInt = #line,
        handler: ExpectationHandler
    ) {
        let asyncExpectation = expectation(description: description)
        handler(description, asyncExpectation)
        waitForExpectations(timeout: timeout) { error in
            EEAssertNotError(error, description, file: file, line: line)
        }
    }
}

/// Asserts the error was received.
func EEAssertError(_ error: Error?, _ description: String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertNotNil(error, "\(description): error expected.", file: file, line: line)
}

/// Asserts no errors were received.
func EEAssertNotError(_ error: Error?, _ description: String, file: StaticString = #file, line: UInt = #line) {
    let errorDescription = error.map(errorDebugDescription) ?? "nil"
    XCTAssertNil(error, "\(description): error: " + errorDescription, file: file, line: line)
}

/// Asserts the error is nil.
func EEAssertNotError(
    _ error: Error?,
    _ description: String,
    _ expectation: XCTestExpectation?,
    file: StaticString = #file,
    line: UInt = #line
) -> Bool {
    if let error = error {
        XCTFail("\(description): no error expected, but got: \(errorDebugDescription(error))", file: file, line: line)
        expectation?.fulfill()
    }
    return error == nil
}

/// Asserts the error is not nil.
func EEAssertError(
    _ error: Error?,
    _ description: String,
    _ expectation: XCTestExpectation?,
    file: StaticString = #file,
    line: UInt = #line
) -> Bool {
    if error == nil {
        XCTFail("\(description): error expected", file: file, line: line)
        expectation?.fulfill()
    }
    return error != nil
}

/// Asserts the result is success.
func EEAssertSuccess<T, E>(
    _ result: Result<T, E>,
    _ description: String,
    _ expectation: XCTestExpectation? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> T? {
    switch result {
        case .success(let value):
            return value
        case .failure(let error):
            XCTFail("\(description): success expected, but got: \(errorDebugDescription(error))", file: file, line: line)
            expectation?.fulfill()
            return nil
    }
}

/// Asserts the variable has non nil value.
func EEAssertNotNil<T>(
    _ value: T?,
    _ description: String,
    _ expectation: XCTestExpectation? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> T? {
    if value == nil {
        XCTFail("\(description): non nil value expected.", file: file, line: line)
        expectation?.fulfill()
    }
    return value
}

/// Asserts the result is failure.
func EEAssertFailure<T, E>(
    _ result: Result<T, E>,
    _ description: String,
    _ expectation: XCTestExpectation? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> E? {
    switch result {
        case .success:
            XCTFail("\(description): failure expected", file: file, line: line)
            expectation?.fulfill()
            return nil
        case .failure(let error):
            return error
    }
}

func errorDebugDescription(_ error: Any) -> String {
    let description = String(describing: error).replacingOccurrences(of: "\n", with: ", ")
    return description
}

#endif
