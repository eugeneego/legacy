//
// TransformerStringConvertible
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import Foundation
import CoreGraphics

public protocol TransformerStringConvertible {
    init?(_ text: String)
}

extension Int: TransformerStringConvertible {}
extension Int8: TransformerStringConvertible {}
extension Int16: TransformerStringConvertible {}
extension Int32: TransformerStringConvertible {}
extension Int64: TransformerStringConvertible {}
extension UInt: TransformerStringConvertible {}
extension UInt8: TransformerStringConvertible {}
extension UInt16: TransformerStringConvertible {}
extension UInt32: TransformerStringConvertible {}
extension UInt64: TransformerStringConvertible {}

extension Float: TransformerStringConvertible {}
extension Double: TransformerStringConvertible {}

extension CGFloat: TransformerStringConvertible {
    public init?(_ text: String) {
        guard let double = Double(text) else { return nil }

        self.init(double)
    }
}
