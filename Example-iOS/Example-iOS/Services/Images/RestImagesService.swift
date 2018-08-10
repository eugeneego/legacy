//
// RestImagesService
// Example-iOS
//
// Created by Eugene Egorov on 20 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import Foundation
import Legacy

class RestImagesService: ImagesService {
    private let rest: LightRestClient

    init(rest: LightRestClient) {
        self.rest = rest
    }

    func images(completion: @escaping (Result<[URL], ImagesError>) -> Void) {
        DispatchQueue.main.async {
            completion(.failure(.unknown(nil)))
        }
    }
}
