//
// Easing
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//
// Based on AHEasing
// https://github.com/warrenm/AHEasing
//
// Credits:
// Robert Penner, http://robertpenner.com/easing/
// Warren Moore, https://warrenmoore.net/
//

import CoreGraphics

// swiftlint:disable variable_name

public struct Easing<T: EasingValueType> {
    // MARK: - Linear

    /// The line y = x
    public static func linear(p: T) -> T {
        return p
    }

    // MARK: - Quadratic

    /// The parabola y = x^2
    public static func quadraticIn(p: T) -> T {
        return p * p
    }

    /// The parabola y = -x^2 + 2x
    public static func quadraticOut(p: T) -> T {
        return -p * (p - 2)
    }

    /// The piecewise quadratic
    /// y = (1/2)((2x)^2)             ; [0, 0.5)
    /// y = -(1/2)((2x-1)*(2x-3) - 1) ; [0.5, 1]
    public static func quadraticInOut(p: T) -> T {
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
    public static func cubicIn(p: T) -> T {
        return p * p * p
    }

    /// The cubic y = (x - 1)^3 + 1
    public static func cubicOut(p: T) -> T {
        let f = p - 1
        return f * f * f + 1
    }

    /// The piecewise cubic
    /// y = (1/2)((2x)^3)       ; [0, 0.5)
    /// y = (1/2)((2x-2)^3 + 2) ; [0.5, 1]
    public static func cubicInOut(p: T) -> T {
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
    public static func quarticIn(p: T) -> T {
        return p * p * p * p
    }

    /// The quartic y = 1 - (x - 1)^4
    public static func quarticOut(p: T) -> T {
        let f = p - 1
        let fff = f * f * f
        return fff * (1 - p) + 1
    }

    /// The piecewise quartic
    /// y = (1/2)((2x)^4)        ; [0, 0.5)
    /// y = -(1/2)((2x-2)^4 - 2) ; [0.5, 1]
    public static func quarticInOut(p: T) -> T {
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
    public static func quinticIn(p: T) -> T {
        return p * p * p * p * p
    }

    /// The quintic y = (x - 1)^5 + 1
    public static func quinticOut(p: T) -> T {
        let f = p - 1
        let ff = f * f
        return ff * ff * f + 1
    }

    /// The piecewise quintic
    /// y = (1/2)((2x)^5)       ; [0, 0.5)
    /// y = (1/2)((2x-2)^5 + 2) ; [0.5, 1]
    public static func quinticInOut(p: T) -> T {
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
    public static func sineIn(p: T) -> T {
        return T.sin((p - 1) * T.pi2) + 1
    }

    /// Quarter-cycle of sine wave (different phase)
    public static func sineOut(p: T) -> T {
        return T.sin(p * T.pi2)
    }

    /// Half sine wave
    public static func sineInOut(p: T) -> T {
        return 0.5 * (1 - T.cos(p * T.pi))
    }

    // MARK: - Circular

    /// Shifted quadrant IV of unit circle
    public static func circularIn(p: T) -> T {
        return 1 - T.sqrt(1 - p * p)
    }

    /// Shifted quadrant II of unit circle
    public static func circularOut(p: T) -> T {
        return T.sqrt((2 - p) * p)
    }

    /// The piecewise circular function
    /// y = (1/2)(1 - sqrt(1 - 4x^2))           ; [0, 0.5)
    /// y = (1/2)(sqrt(-(2x - 3)*(2x - 1)) + 1) ; [0.5, 1]
    public static func circularInOut(p: T) -> T {
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
    public static func exponentialIn(p: T) -> T {
        return (p == 0.0) ? p : T.pow(2, 10 * (p - 1))
    }

    /// The exponential function y = -2^(-10x) + 1
    public static func exponentialOut(p: T) -> T {
        return (p == 1.0) ? p : 1 - T.pow(2, -10 * p)
    }

    /// The piecewise exponential
    /// y = (1/2)2^(10(2x - 1))         ; [0,0.5)
    /// y = -(1/2)*2^(-10(2x - 1))) + 1 ; [0.5,1]
    public static func exponentialInOut(p: T) -> T {
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
    public static func elasticIn(p: T) -> T {
        return T.sin(13 * T.pi2 * p) * T.pow(2, 10 * (p - 1))
    }

    /// The damped sine wave y = sin(-13pi/2*(x + 1))*pow(2, -10x) + 1
    public static func elasticOut(p: T) -> T {
        let f1 = T.pi2 * (p + 1)
        return T.sin(-13 * f1) * T.pow(2, -10 * p) + 1
    }

    /// The piecewise exponentially-damped sine wave:
    /// y = (1/2)*sin(13pi/2*(2*x))*pow(2, 10 * ((2*x) - 1))      ; [0,0.5)
    /// y = (1/2)*(sin(-13pi/2*((2x-1)+1))*pow(2,-10(2*x-1)) + 2) ; [0.5, 1]
    public static func elasticInOut(p: T) -> T {
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
    public static func backIn(p: T) -> T {
        return p * p * p - p * T.sin(p * T.pi)
    }

    /// The overshooting cubic y = 1-((1-x)^3-(1-x)*sin((1-x)*pi))
    public static func backOut(p: T) -> T {
        let f = 1 - p
        let fff = f * f * f
        return 1 - (fff - f * T.sin(f * T.pi))
    }

    /// The piecewise overshooting cubic function:
    /// y = (1/2)*((2x)^3-(2x)*sin(2*x*pi))           ; [0, 0.5)
    /// y = (1/2)*(1-((1-x)^3-(1-x)*sin((1-x)*pi))+1) ; [0.5, 1]
    public static func backInOut(p: T) -> T {
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

    public static func bounceIn(p: T) -> T {
        return 1 - bounceOut(1 - p)
    }

    public static func bounceOut(p: T) -> T {
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

    public static func bounceInOut(p: T) -> T {
        if p < 0.5 {
            return 0.5 * bounceIn(p * 2)
        } else {
            return 0.5 * bounceOut(p * 2 - 1) + 0.5
        }
    }
}

public protocol EasingValueType: IntegerLiteralConvertible, FloatLiteralConvertible {
    func + (left: Self, right: Self) -> Self
    func - (left: Self, right: Self) -> Self
    func * (left: Self, right: Self) -> Self
    func / (left: Self, right: Self) -> Self
    prefix func - (x: Self) -> Self

    func < (lhs: Self, rhs: Self) -> Bool
    func > (lhs: Self, rhs: Self) -> Bool
    func == (lhs: Self, rhs: Self) -> Bool

    static var pi: Self { get }
    static var pi2: Self { get }

    static func pow(lhs: Self, _ rhs: Self) -> Self
    static func sqrt(x: Self) -> Self

    static func sin(x: Self) -> Self
    static func cos(x: Self) -> Self
}

extension Float: EasingValueType {
    public static var pi: Float { return Float(M_PI) }
    public static var pi2: Float { return Float(M_PI_2) }

    public static func pow(lhs: Float, _ rhs: Float) -> Float {
        return Darwin.pow(lhs, rhs)
    }

    public static func sqrt(x: Float) -> Float {
        return Darwin.sqrt(x)
    }

    public static func sin(x: Float) -> Float {
        return Darwin.sin(x)
    }

    public static func cos(x: Float) -> Float {
        return Darwin.cos(x)
    }
}

extension Double: EasingValueType {
    public static var pi: Double { return M_PI }
    public static var pi2: Double { return M_PI_2 }

    public static func pow(lhs: Double, _ rhs: Double) -> Double {
        return Darwin.pow(lhs, rhs)
    }

    public static func sqrt(x: Double) -> Double {
        return Darwin.sqrt(x)
    }

    public static func sin(x: Double) -> Double {
        return Darwin.sin(x)
    }

    public static func cos(x: Double) -> Double {
        return Darwin.cos(x)
    }
}

extension CGFloat: EasingValueType {
    public static var pi: CGFloat {
        return CGFloat(M_PI)
    }
    public static var pi2: CGFloat {
        return CGFloat(M_PI_2)
    }

    public static func pow(lhs: CGFloat, _ rhs: CGFloat) -> CGFloat {
        return CoreGraphics.pow(lhs, rhs)
    }

    public static func sqrt(x: CGFloat) -> CGFloat {
        return CoreGraphics.sqrt(x)
    }

    public static func sin(x: CGFloat) -> CGFloat {
        return CoreGraphics.sin(x)
    }

    public static func cos(x: CGFloat) -> CGFloat {
        return CoreGraphics.cos(x)
    }
}

// swiftlint:enable variable_name
