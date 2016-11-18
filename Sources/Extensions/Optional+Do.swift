//
// Optional (Do)
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

extension Optional {
    func `do`(_ action: (Wrapped) throws -> Void) rethrows {
        if case .some(let value) = self {
            try action(value)
        }
    }
}
