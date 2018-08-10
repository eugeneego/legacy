//
// MockImagesService
// Example-iOS
//
// Created by Eugene Egorov on 20 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import Foundation
import Legacy

class MockImagesService: ImagesService {
    private let images: [URL] = [
        "https://unsplash.com/photos/3RAl7RNLMTU/download?force=true",
        "https://unsplash.com/photos/LBAEha7kxFU/download?force=true",
        "https://unsplash.com/photos/EoC_IuYmtug/download?force=true",
        "https://unsplash.com/photos/7wWRXewYCH4/download?force=true",
        "https://unsplash.com/photos/mRwk8fIyBO4/download?force=true",
        "https://unsplash.com/photos/xKOFnbNwUrQ/download?force=true",
        "https://unsplash.com/photos/lHX10-lCga4/download?force=true",
        "https://unsplash.com/photos/N74s_7Yfvuo/download?force=true",
        "https://unsplash.com/photos/-4kDvstCcBY/download?force=true",
        "https://unsplash.com/photos/Ps6OvCkHSlM/download?force=true",
        "https://unsplash.com/photos/n9bZ_e1ETxM/download?force=true",
        "https://unsplash.com/photos/kY5eDeqkScU/download?force=true",
        "https://unsplash.com/photos/6zcbxACAbPk/download?force=true",
        "https://unsplash.com/photos/VhsN15DbAt8/download?force=true",
        "https://unsplash.com/photos/0wsnJWonXFs/download?force=true",
        "https://unsplash.com/photos/bR4lTpjKW2o/download?force=true",
        "https://unsplash.com/photos/egUpLk34J4s/download?force=true",
        "https://unsplash.com/photos/biTZAppML9Q/download?force=true",
        "https://unsplash.com/photos/UyFISmyVSzM/download?force=true",
        "https://unsplash.com/photos/QKHmi6ENAmk/download?force=true",
    ].compactMap(URL.init)

    func images(completion: @escaping (Result<[URL], ImagesError>) -> Void) {
        DispatchQueue.main.async {
            completion(.success(self.images))
        }
    }
}
