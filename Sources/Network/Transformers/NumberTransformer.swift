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

    public func fromAny(value: AnyObject?) -> T? {
        return (value as? NSNumber).flatMap(T.fromNumber) ?? (value as? T)
    }

    public func toAny(value: T?) -> AnyObject? {
        return value?.toNumber()
    }
}

public protocol NumberConvertible {
    static func fromNumber(number: NSNumber) -> Self
    func toNumber() -> NSNumber
}

extension Int: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> Int {
        return number.integerValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(integer: self)
    }
}

extension Int8: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> Int8 {
        return number.charValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(char: self)
    }
}

extension Int16: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> Int16 {
        return number.shortValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(short: self)
    }
}

extension Int32: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> Int32 {
        return number.intValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(int: self)
    }
}

extension Int64: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> Int64 {
        return number.longLongValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(longLong: self)
    }
}

extension UInt: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> UInt {
        return number.unsignedIntegerValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(unsignedInteger: self)
    }
}

extension UInt8: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> UInt8 {
        return number.unsignedCharValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(unsignedChar: self)
    }
}

extension UInt16: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> UInt16 {
        return number.unsignedShortValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(unsignedShort: self)
    }
}

extension UInt32: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> UInt32 {
        return number.unsignedIntValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(unsignedInt: self)
    }
}

extension UInt64: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> UInt64 {
        return number.unsignedLongLongValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(unsignedLongLong: self)
    }
}

extension Float: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> Float {
        return number.floatValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(float: self)
    }
}

extension Double: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> Double {
        return number.doubleValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(double: self)
    }
}

extension CGFloat: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> CGFloat {
        return CGFloat(number.doubleValue)
    }

    public func toNumber() -> NSNumber {
        return NSNumber(double: Double(self))
    }
}

extension Bool: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> Bool {
        return number.boolValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber(bool: self)
    }
}

extension String: NumberConvertible {
    public static func fromNumber(number: NSNumber) -> String {
        return number.stringValue
    }

    public func toNumber() -> NSNumber {
        return NSNumber()
    }
}
