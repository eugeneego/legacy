//
// NumberConvertible
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation
import CoreGraphics

public protocol NumberConvertible {
    static func fromNumber(_ number: NSNumber) -> Self
    func toNumber() -> NSNumber
}

extension Int: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Int {
        number.intValue
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}

extension Int8: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Int8 {
        number.int8Value
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}

extension Int16: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Int16 {
        number.int16Value
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}

extension Int32: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Int32 {
        number.int32Value
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}

extension Int64: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Int64 {
        number.int64Value
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}

extension UInt: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> UInt {
        number.uintValue
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}

extension UInt8: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> UInt8 {
        number.uint8Value
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}

extension UInt16: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> UInt16 {
        number.uint16Value
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}

extension UInt32: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> UInt32 {
        number.uint32Value
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}

extension UInt64: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> UInt64 {
        number.uint64Value
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}

extension Float: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Float {
        number.floatValue
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}

extension Double: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Double {
        number.doubleValue
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}

extension CGFloat: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> CGFloat {
        CGFloat(number.doubleValue)
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: Double(self))
    }
}

extension Bool: NumberConvertible {
    public static func fromNumber(_ number: NSNumber) -> Bool {
        number.boolValue
    }

    public func toNumber() -> NSNumber {
        NSNumber(value: self)
    }
}
