//
// DependencyInjectionContainer
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public protocol DependencyInjectionContainer {
    func resolve(object: Any)
}
