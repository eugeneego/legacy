//
// Configurator
// Example-iOS
//
// Created by Eugene Egorov on 29 April 2017.
// Copyright (c) 2017 Eugene Egorov. All rights reserved.
//

import EEUtilities

protocol Configurator {
    func create() -> DependencyInjectionContainer
}
