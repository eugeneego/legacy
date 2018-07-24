//
// ImagesService
// Example-iOS
//
// Created by Eugene Egorov on 20 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import Foundation
import Legacy

enum ImagesError: Error {
    case network(NetworkError)
    case unknown(Error?)
}

protocol ImagesService {
    func images(completion: @escaping (Result<[URL], ImagesError>) -> Void)
}
