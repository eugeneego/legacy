//
// NumberTransformer
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation
import CoreGraphics

public struct NumberTransformer<Number: NumberConvertible>: Transformer {
    public typealias T = Number

    public func fromAny(_ value: Any?) -> T? {
        return (value as? NSNumber).flatMap(T.fromNumber) ?? (value as? T)
    }

    public func toAny(_ value: T?) -> Any? {
        return value?.toNumber()
    }
}

public protocol NumberConvertible {
    static func fromNumber(_ number: NSNumber) -> Self
    func toNumber() -> NSNumber
}

extension Int: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Int {
        return number.intValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension Int8: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Int8 {
        return number.int8Value
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension Int16: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Int16 {
        return number.int16Value
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension Int32: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Int32 {
        return number.int32Value
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension Int64: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Int64 {
        return number.int64Value
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension UInt: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> UInt {
        return number.uintValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension UInt8: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> UInt8 {
        return number.uint8Value
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension UInt16: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> UInt16 {
        return number.uint16Value
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension UInt32: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> UInt32 {
        return number.uint32Value
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension UInt64: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> UInt64 {
        return number.uint64Value
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension Float: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Float {
        return number.floatValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension Double: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Double {
        return number.doubleValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension CGFloat: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> CGFloat {
        return CGFloat(number.doubleValue)
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: Double(self))
    }
}

extension Bool: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Bool {
        return number.boolValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(value: self)
    }
}

extension String: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> String {
        return number.stringValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber()
    }
}
