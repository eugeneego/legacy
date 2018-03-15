//
// UIColor (Hex)
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if os(iOS)
import UIKit
public typealias EEColor = UIColor
#elseif os(OSX)
import AppKit
public typealias EEColor = NSColor
#endif

public extension EEColor {
    /**
        Hex representation of a color with alpha channel.

        - returns: AARRGGBB string
     */
    public var hexARGB: String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "%02X%02X%02X%02X", Int(alpha * 255), Int(red * 255), Int(green * 255), Int(blue * 255))
    }

    /**
        Hex representation of a color without alpha channel.

        - returns: RRGGBB string
     */
    public var hexRGB: String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }

    /**
        Parse a string with a hex representation of a color.

        Acceptable formats:
        - RGB
        - ARGB
        - RRGGBB
        - AARRGGBB

        - parameter hex: The string to parse, may be prefixed with #.
        - parameter default: The default color for fallback.

        - returns: A parsed color or a default value if parsing is failed.
     */
    public static func from(hex: String, default: EEColor) -> EEColor {
        return from(hex: hex) ?? `default`
    }

    /**
        Parse a string with a hex representation of a color.

        Acceptable formats:
        - RGB
        - ARGB
        - RRGGBB
        - AARRGGBB

        - parameter hex: The string to parse, may be prefixed with #.

        - returns: A parsed color or crash if parsing is failed.
     */
    public static func fromRequired(hex: String) -> EEColor {
        guard let color = from(hex: hex) else {
            fatalError("Cannot create a color from hex string: \(hex)")
        }
        return color
    }

    /**
        Parse a string with a hex representation of a color.

        Acceptable formats:
        - RGB
        - ARGB
        - RRGGBB
        - AARRGGBB

        - parameter hex: The string to parse, may be prefixed with #.

        - returns: A parsed color or nil if parsing is failed.
     */
    public static func from(hex: String) -> EEColor? {
        guard !hex.isEmpty else { return nil }

        var s = hex.uppercased()
        if s[s.startIndex] == "#" {
            s.remove(at: s.startIndex)
        }

        guard hex.count >= 3 else { return nil }
        guard let rgb = UInt32(s, radix: 16) else { return nil }

        let a, r, g, b: UInt32
        switch s.count {
            case 3: // RGB (12-bit) "RGB"
                (a, r, g, b) = (255, (rgb >> 8 & 0xF) * 17, (rgb >> 4 & 0xF) * 17, (rgb & 0xF) * 17)
            case 4: // ARGB (16-bit) "ARGB"
                (a, r, g, b) = ((rgb >> 12 & 0xF) * 17, (rgb >> 8 & 0xF) * 17, (rgb >> 4 & 0xF) * 17, (rgb & 0xF) * 17)
            case 6: // RGB (24-bit) "RRGGBB"
                (a, r, g, b) = (255, rgb >> 16, rgb >> 8 & 0xFF, rgb & 0xFF)
            case 8: // ARGB (32-bit) "AARRGGBB"
                (a, r, g, b) = (rgb >> 24, rgb >> 16 & 0xFF, rgb >> 8 & 0xFF, rgb & 0xFF)
            default:
                return nil
        }

        return EEColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
