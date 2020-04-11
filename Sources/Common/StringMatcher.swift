//
// StringMatcher
// Legacy
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public enum StringMatcher {
    case equal(String)
    case prefix(String)
    case suffix(String)
}

public func ~= (pattern: StringMatcher, value: String) -> Bool {
    switch pattern {
        case .equal(let string):
            return value == string
        case .prefix(let prefix):
            return value.hasPrefix(prefix)
        case .suffix(let suffix):
            return value.hasSuffix(suffix)
    }
}

public func ~=<T> (pattern: (T) -> Bool, value: T) -> Bool {
    pattern(value)
}
