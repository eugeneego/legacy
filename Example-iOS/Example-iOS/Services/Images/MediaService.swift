//
// MediaService
// Example-iOS
//
// Created by Eugene Egorov on 20 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import Foundation
import Legacy

enum MediaError: Error {
    case network(NetworkError)
    case unknown(Error?)
}

enum Media {
    case image(URL)
    case video(URL, thumbnail: URL?)
}

protocol MediaService {
    func media(completion: @escaping (Result<[Media], MediaError>) -> Void)
}
