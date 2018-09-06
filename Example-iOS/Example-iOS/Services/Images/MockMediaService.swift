//
// MockMediaService
// Example-iOS
//
// Created by Eugene Egorov on 20 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import Foundation
import Legacy

class MockMediaService: MediaService {
    // swiftlint:disable force_unwrapping
    private let localMedia: [Media] = [
        .video(URL(string: "app:///big_buck_bunny.mp4")!, thumbnail: URL(string: "app:///big_buck_bunny.jpg")),
        .video(URL(string: "app:///echo-hereweare.mp4")!, thumbnail: URL(string: "app:///echo-hereweare.jpg")),
        .image(URL(string: "app:///01-kyle-loftus-673612-unsplash.jpg")!),
        .image(URL(string: "app:///02-shane-rounce-384233-unsplash.jpg")!),
        .image(URL(string: "app:///03-tim-bennett-607824-unsplash.jpg")!),
        .image(URL(string: "app:///04-jaron-nix-643585-unsplash.jpg")!),
        .image(URL(string: "app:///05-dash-gualberto-34284-unsplash.jpg")!),
        .image(URL(string: "app:///06-vladimir-kudinov-92149-unsplash.jpg")!),
        .image(URL(string: "app:///07-marius-ott-623692-unsplash.jpg")!),
        .image(URL(string: "app:///08-artem-bali-565223-unsplash.jpg")!),
        .image(URL(string: "app:///09-andreas-fidler-400111-unsplash.jpg")!),
        .image(URL(string: "app:///10-muhammad-wahyu-nur-pratama-189040-unsplash.jpg")!),
        .image(URL(string: "app:///11-fancycrave-417113-unsplash.jpg")!),
        .image(URL(string: "app:///12-fancycrave-458019-unsplash.jpg")!),
        .image(URL(string: "app:///13-dan-gold-497434-unsplash.jpg")!),
        .image(URL(string: "app:///14-siarhei-horbach-229106-unsplash.jpg")!),
        .image(URL(string: "app:///15-drew-beamer-457831-unsplash.jpg")!),
        .image(URL(string: "app:///16-clem-onojeghuo-631885-unsplash.jpg")!),
        .image(URL(string: "app:///17-milkovi-644010-unsplash.jpg")!),
        .image(URL(string: "app:///18-joao-silas-636979-unsplash.jpg")!),
        .image(URL(string: "app:///19-patrick-perkins-342329-unsplash.jpg")!),
        .image(URL(string: "app:///20-ryoji-iwata-669965-unsplash.jpg")!),
    ]

    private let remoteMedia: [Media] = [
        .video(URL(string: "https://github.com/mediaelement/mediaelement-files/raw/master/big_buck_bunny.mp4")!,
            thumbnail: URL(string: "https://github.com/mediaelement/mediaelement-files/raw/master/big_buck_bunny.jpg")),
        .video(URL(string: "https://github.com/mediaelement/mediaelement-files/raw/master/echo-hereweare.mp4")!,
            thumbnail: URL(string: "https://github.com/mediaelement/mediaelement-files/raw/master/echo-hereweare.jpg")),
        .image(URL(string: "https://unsplash.com/photos/3RAl7RNLMTU/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/LBAEha7kxFU/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/EoC_IuYmtug/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/7wWRXewYCH4/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/mRwk8fIyBO4/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/xKOFnbNwUrQ/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/lHX10-lCga4/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/N74s_7Yfvuo/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/-4kDvstCcBY/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/Ps6OvCkHSlM/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/n9bZ_e1ETxM/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/kY5eDeqkScU/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/6zcbxACAbPk/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/VhsN15DbAt8/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/0wsnJWonXFs/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/bR4lTpjKW2o/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/egUpLk34J4s/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/biTZAppML9Q/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/UyFISmyVSzM/download?force=true")!),
        .image(URL(string: "https://unsplash.com/photos/QKHmi6ENAmk/download?force=true")!),
    ]
    // swiftlint:enable force_unwrapping

    func media(completion: @escaping (Result<[Media], MediaError>) -> Void) {
        DispatchQueue.main.async {
            completion(.success(self.localMedia))
        }
    }
}
