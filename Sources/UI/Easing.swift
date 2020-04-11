//
// Easing
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//
// Based on AHEasing
// https://github.com/warrenm/AHEasing
//
// Credits:
// Robert Penner, http://robertpenner.com/easing/
// Warren Moore, https://warrenmoore.net/
//

import CoreGraphics

// swiftlint:disable identifier_name

public struct Easing<T: EasingValueType> {
    // MARK: - Linear

    /// The line y = x
    public static func linear(_ p: T) -> T {
        p
    }

    // MARK: - Quadratic

    /// The parabola y = x^2
    public static func quadraticIn(_ p: T) -> T {
        p * p
    }

    /// The parabola y = -x^2 + 2x
    public static func quadraticOut(_ p: T) -> T {
        -p * (p - 2)
    }

    /// The piecewise quadratic
    /// y = (1/2)((2x)^2)             ; [0, 0.5)
    /// y = -(1/2)((2x-1)*(2x-3) - 1) ; [0.5, 1]
    public static func quadraticInOut(_ p: T) -> T {
        let pp2 = 2 * p * p
        if p < 0.5 {
            return pp2
        } else {
            let f1 = 4 * p - 1
            return -pp2 + f1
        }
    }

    // MARK: - Cubic

    /// The cubic y = x^3
    public static func cubicIn(_ p: T) -> T {
        p * p * p
    }

    /// The cubic y = (x - 1)^3 + 1
    public static func cubicOut(_ p: T) -> T {
        let f = p - 1
        return f * f * f + 1
    }

    /// The piecewise cubic
    /// y = (1/2)((2x)^3)       ; [0, 0.5)
    /// y = (1/2)((2x-2)^3 + 2) ; [0.5, 1]
    public static func cubicInOut(_ p: T) -> T {
        if p < 0.5 {
            let ppp = p * p * p
            return 4 * ppp
        } else {
            let f = 2 * p - 2
            let fff = f * f * f
            return 0.5 * fff + 1
        }
    }

    // MARK: - Quartic

    /// The quartic x^4
    public static func quarticIn(_ p: T) -> T {
        p * p * p * p
    }

    /// The quartic y = 1 - (x - 1)^4
    public static func quarticOut(_ p: T) -> T {
        let f = p - 1
        let fff = f * f * f
        return fff * (1 - p) + 1
    }

    /// The piecewise quartic
    /// y = (1/2)((2x)^4)        ; [0, 0.5)
    /// y = -(1/2)((2x-2)^4 - 2) ; [0.5, 1]
    public static func quarticInOut(_ p: T) -> T {
        if p < 0.5 {
            let pppp = p * p * p * p
            return 8 * pppp
        } else {
            let f = p - 1
            let ffff = f * f * f * f
            return -8 * ffff + 1
        }
    }

    // MARK: - Quintic

    /// The quintic y = x^5
    public static func quinticIn(_ p: T) -> T {
        p * p * p * p * p
    }

    /// The quintic y = (x - 1)^5 + 1
    public static func quinticOut(_ p: T) -> T {
        let f = p - 1
        let ff = f * f
        return ff * ff * f + 1
    }

    /// The piecewise quintic
    /// y = (1/2)((2x)^5)       ; [0, 0.5)
    /// y = (1/2)((2x-2)^5 + 2) ; [0.5, 1]
    public static func quinticInOut(_ p: T) -> T {
        if p < 0.5 {
            let p5 = p * p * p * p * p
            return 16 * p5
        } else {
            let f = 2 * p - 2
            let f5 = f * f * f * f * f
            return  0.5 * f5 + 1
        }
    }

    // MARK: - Sine

    /// Quarter-cycle of sine wave
    public static func sineIn(_ p: T) -> T {
        T.sin((p - 1) * T.pi2) + 1
    }

    /// Quarter-cycle of sine wave (different phase)
    public static func sineOut(_ p: T) -> T {
        T.sin(p * T.pi2)
    }

    /// Half sine wave
    public static func sineInOut(_ p: T) -> T {
        0.5 * (1 - T.cos(p * T.pi))
    }

    // MARK: - Circular

    /// Shifted quadrant IV of unit circle
    public static func circularIn(_ p: T) -> T {
        1 - T.sqrt(1 - p * p)
    }

    /// Shifted quadrant II of unit circle
    public static func circularOut(_ p: T) -> T {
        T.sqrt((2 - p) * p)
    }

    /// The piecewise circular function
    /// y = (1/2)(1 - sqrt(1 - 4x^2))           ; [0, 0.5)
    /// y = (1/2)(sqrt(-(2x - 3)*(2x - 1)) + 1) ; [0.5, 1]
    public static func circularInOut(_ p: T) -> T {
        if p < 0.5 {
            let pp = p * p
            return 0.5 * (1 - T.sqrt(1 - 4 * pp))
        } else {
            let f1 = 2 * p - 3
            let f2 = 2 * p - 1
            return 0.5 * (T.sqrt(-f1 * f2) + 1)
        }
    }

    // MARK: - Exponential

    /// The exponential function y = 2^(10(x - 1))
    public static func exponentialIn(_ p: T) -> T {
        (p == 0.0) ? p : T.pow(2, 10 * (p - 1))
    }

    /// The exponential function y = -2^(-10x) + 1
    public static func exponentialOut(_ p: T) -> T {
        (p == 1.0) ? p : 1 - T.pow(2, -10 * p)
    }

    /// The piecewise exponential
    /// y = (1/2)2^(10(2x - 1))         ; [0,0.5)
    /// y = -(1/2)*2^(-10(2x - 1))) + 1 ; [0.5,1]
    public static func exponentialInOut(_ p: T) -> T {
        if p == 0.0 || p == 1.0 {
            return p
        }

        if p < 0.5 {
            return 0.5 * T.pow(2, 20 * p - 10)
        } else {
            return -0.5 * T.pow(2, -20 * p + 10) + 1
        }
    }

    // MARK: - Elastic

    /// The damped sine wave y = sin(13pi/2*x)*pow(2, 10 * (x - 1))
    public static func elasticIn(_ p: T) -> T {
        T.sin(13 * T.pi2 * p) * T.pow(2, 10 * (p - 1))
    }

    /// The damped sine wave y = sin(-13pi/2*(x + 1))*pow(2, -10x) + 1
    public static func elasticOut(_ p: T) -> T {
        let f1 = T.pi2 * (p + 1)
        return T.sin(-13 * f1) * T.pow(2, -10 * p) + 1
    }

    /// The piecewise exponentially-damped sine wave:
    /// y = (1/2)*sin(13pi/2*(2*x))*pow(2, 10 * ((2*x) - 1))      ; [0,0.5)
    /// y = (1/2)*(sin(-13pi/2*((2x-1)+1))*pow(2,-10(2*x-1)) + 2) ; [0.5, 1]
    public static func elasticInOut(_ p: T) -> T {
        let p2 = 2 * p
        let pi132 = 13 * T.pi2 * p2
        let p10 = 10 * (p2 - 1)
        if p < 0.5 {
            return 0.5 * T.sin(pi132) * T.pow(2, p10)
        } else {
            return 0.5 * (T.sin(-pi132) * T.pow(2, -p10) + 2)
        }
    }

    // MARK: - Back

    /// The overshooting cubic y = x^3-x*sin(x*pi)
    public static func backIn(_ p: T) -> T {
        let p3 = p * p * p
        let psin = p * T.sin(p * T.pi)
        return p3 - psin
    }

    /// The overshooting cubic y = 1-((1-x)^3-(1-x)*sin((1-x)*pi))
    public static func backOut(_ p: T) -> T {
        let f = 1 - p
        let fff = f * f * f
        return 1 - (fff - f * T.sin(f * T.pi))
    }

    /// The piecewise overshooting cubic function:
    /// y = (1/2)*((2x)^3-(2x)*sin(2*x*pi))           ; [0, 0.5)
    /// y = (1/2)*(1-((1-x)^3-(1-x)*sin((1-x)*pi))+1) ; [0.5, 1]
    public static func backInOut(_ p: T) -> T {
        if p < 0.5 {
            let f = 2 * p
            let fff = f * f * f
            let g = fff - f * T.sin(f * T.pi)
            return 0.5 * g
        } else {
            let f = -2 * p
            let fff = f * f * f
            let g = fff - f * T.sin(f * T.pi)
            return 1 - 0.5 * g
        }
    }

    // MARK: - Bounce

    public static func bounceIn(_ p: T) -> T {
        1 - bounceOut(1 - p)
    }

    public static func bounceOut(_ p: T) -> T {
        let pp = p * p
        if p < 4.0 / 11.0 {
            return (121 * pp) / 16.0
        } else if p < 8.0 / 11.0 {
            let f1 = 363.0 / 40.0 * pp
            let f2 = 99.0 / 10.0 * p
            let f3: T = 17.0 / 5.0
            return f1 - f2 + f3
        } else if p < 9.0 / 10.0 {
            let f1 = 4356.0 / 361.0 * pp
            let f2 = 35442.0 / 1805.0 * p
            let f3: T = 16061.0 / 1805.0
            return f1 - f2 + f3
        } else {
            let f1 = 54.0 / 5.0 * pp
            let f2 = 513.0 / 25.0 * p
            let f3: T = 268.0 / 25.0
            return f1 - f2 + f3
        }
    }

    public static func bounceInOut(_ p: T) -> T {
        if p < 0.5 {
            return 0.5 * bounceIn(p * 2)
        } else {
            return 0.5 * bounceOut(p * 2 - 1) + 0.5
        }
    }
}

public protocol EasingValueType: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    static func + (left: Self, right: Self) -> Self
    static func - (left: Self, right: Self) -> Self
    static func * (left: Self, right: Self) -> Self
    static func / (left: Self, right: Self) -> Self
    prefix static func - (x: Self) -> Self

    static func < (lhs: Self, rhs: Self) -> Bool
    static func > (lhs: Self, rhs: Self) -> Bool
    static func == (lhs: Self, rhs: Self) -> Bool

    static var pi: Self { get }
    static var pi2: Self { get }

    static func pow(_ lhs: Self, _ rhs: Self) -> Self
    static func sqrt(_ x: Self) -> Self

    static func sin(_ x: Self) -> Self
    static func cos(_ x: Self) -> Self
}

extension Float: EasingValueType {
    public static let pi2: Float = .pi / 2

    public static func pow(_ lhs: Float, _ rhs: Float) -> Float {
        Darwin.pow(lhs, rhs)
    }

    public static func sqrt(_ x: Float) -> Float {
        Darwin.sqrt(x)
    }

    public static func sin(_ x: Float) -> Float {
        Darwin.sin(x)
    }

    public static func cos(_ x: Float) -> Float {
        Darwin.cos(x)
    }
}

extension Double: EasingValueType {
    public static let pi2: Double = .pi / 2

    public static func pow(_ lhs: Double, _ rhs: Double) -> Double {
        Darwin.pow(lhs, rhs)
    }

    public static func sqrt(_ x: Double) -> Double {
        Darwin.sqrt(x)
    }

    public static func sin(_ x: Double) -> Double {
        Darwin.sin(x)
    }

    public static func cos(_ x: Double) -> Double {
        Darwin.cos(x)
    }
}

extension CGFloat: EasingValueType {
    public static let pi2: CGFloat = .pi / 2

    public static func pow(_ lhs: CGFloat, _ rhs: CGFloat) -> CGFloat {
        CoreGraphics.pow(lhs, rhs)
    }

    public static func sqrt(_ x: CGFloat) -> CGFloat {
        CoreGraphics.sqrt(x)
    }

    public static func sin(_ x: CGFloat) -> CGFloat {
        CoreGraphics.sin(x)
    }

    public static func cos(_ x: CGFloat) -> CGFloat {
        CoreGraphics.cos(x)
    }
}

// swiftlint:enable identifier_name
