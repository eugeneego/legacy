//
// Arithmetic
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import CoreGraphics

public protocol Arithmetic {
    func + (left: Self, right: Self) -> Self
    func - (left: Self, right: Self) -> Self
    func * (left: Self, right: Self) -> Self
    func / (left: Self, right: Self) -> Self

    func += (inout left: Self, right: Self)
    func -= (inout left: Self, right: Self)
    func *= (inout left: Self, right: Self)
    func /= (inout left: Self, right: Self)
}

public protocol BitArithmetic {
    func & (left: Self, right: Self) -> Self
    func | (left: Self, right: Self) -> Self
    func ^ (left: Self, right: Self) -> Self
    prefix func ~ (left: Self) -> Self

    func &= (inout left: Self, right: Self)
    func |= (inout left: Self, right: Self)
    func ^= (inout left: Self, right: Self)
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
