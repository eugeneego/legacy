//
// StringMatcher
// EE Utilities
//
// Copyright (c) 2015 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public enum StringMatcher {
    case Equal(String)
    case Prefix(String)
    case Suffix(String)
}

public func ~= (pattern: StringMatcher, value: String) -> Bool {
    switch pattern {
        case .Equal(let string):
            return value == string
        case .Prefix(let prefix):
            return value.hasPrefix(prefix)
        case .Suffix(let suffix):
            return value.hasSuffix(suffix)
    }
}

public func ~=<T> (pattern: T -> Bool, value: T) -> Bool {
    return pattern(value)
}

public func hasPrefix(prefix: String) -> (String -> Bool) {
    return { value in
        value.hasPrefix(prefix)
    }
}
