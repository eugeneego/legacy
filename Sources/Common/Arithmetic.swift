//
// Arithmetic
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import CoreGraphics

public protocol Arithmetic {
    static func + (left: Self, right: Self) -> Self
    static func - (left: Self, right: Self) -> Self
    static func * (left: Self, right: Self) -> Self
    static func / (left: Self, right: Self) -> Self

    static func += (left: inout Self, right: Self)
    static func -= (left: inout Self, right: Self)
    static func *= (left: inout Self, right: Self)
    static func /= (left: inout Self, right: Self)
}

public protocol BitArithmetic {
    static func & (left: Self, right: Self) -> Self
    static func | (left: Self, right: Self) -> Self
    static func ^ (left: Self, right: Self) -> Self
    prefix static func ~ (left: Self) -> Self

    static func &= (left: inout Self, right: Self)
    static func |= (left: inout Self, right: Self)
    static func ^= (left: inout Self, right: Self)
}

extension Int: BitArithmetic, Arithmetic {}
extension Int8: BitArithmetic, Arithmetic {}
extension Int16: BitArithmetic, Arithmetic {}
extension Int32: BitArithmetic, Arithmetic {}
extension Int64: BitArithmetic, Arithmetic {}

extension UInt: BitArithmetic, Arithmetic {}
extension UInt8: BitArithmetic, Arithmetic {}
extension UInt16: BitArithmetic, Arithmetic {}
extension UInt32: BitArithmetic, Arithmetic {}
extension UInt64: BitArithmetic, Arithmetic {}

extension CGFloat: Arithmetic {}
extension Float: Arithmetic {}
extension Double: Arithmetic {}
