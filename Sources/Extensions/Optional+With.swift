//
// Optional (With)
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public extension Optional {
    @discardableResult
    func with(_ action: (Wrapped) throws -> Void) rethrows -> Optional {
        if let value = self {
            try action(value)
        }
        return self
    }
}
