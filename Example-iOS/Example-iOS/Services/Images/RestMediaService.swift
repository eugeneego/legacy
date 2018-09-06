//
// RestMediaService
// Example-iOS
//
// Created by Eugene Egorov on 20 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import Foundation
import Legacy

class RestMediaService: MediaService {
    private let rest: LightRestClient

    init(rest: LightRestClient) {
        self.rest = rest
    }

    func media(completion: @escaping (Result<[Media], MediaError>) -> Void) {
        DispatchQueue.main.async {
            completion(.failure(.unknown(nil)))
        }
    }
}
