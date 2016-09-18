//
// DateFormatter (Format)
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import Foundation

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()

        self.dateFormat = dateFormat
    }
}
