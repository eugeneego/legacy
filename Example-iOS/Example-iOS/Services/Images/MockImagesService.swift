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
    private let localImages: [URL] = [
        "01-kyle-loftus-673612-unsplash.jpg",
        "02-shane-rounce-384233-unsplash.jpg",
        "03-tim-bennett-607824-unsplash.jpg",
        "04-jaron-nix-643585-unsplash.jpg",
        "05-dash-gualberto-34284-unsplash.jpg",
        "06-vladimir-kudinov-92149-unsplash.jpg",
        "07-marius-ott-623692-unsplash.jpg",
        "08-artem-bali-565223-unsplash.jpg",
        "09-andreas-fidler-400111-unsplash.jpg",
        "10-muhammad-wahyu-nur-pratama-189040-unsplash.jpg",
        "11-fancycrave-417113-unsplash.jpg",
        "12-fancycrave-458019-unsplash.jpg",
        "13-dan-gold-497434-unsplash.jpg",
        "14-siarhei-horbach-229106-unsplash.jpg",
        "15-drew-beamer-457831-unsplash.jpg",
        "16-clem-onojeghuo-631885-unsplash.jpg",
        "17-milkovi-644010-unsplash.jpg",
        "18-joao-silas-636979-unsplash.jpg",
        "19-patrick-perkins-342329-unsplash.jpg",
        "20-ryoji-iwata-669965-unsplash.jpg",
    ].map { "app:///\($0)" }.compactMap(URL.init)

    private let remoteImages: [URL] = [
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
            completion(.success(self.localImages))
        }
    }
}
