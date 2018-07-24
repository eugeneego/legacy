//
// ImagesViewController
// Example-iOS
//
// Created by Eugene Egorov on 20 July 2018.
// Copyright (c) 2018 Eugene Egorov. All rights reserved.
//

import UIKit
import Legacy

class ImagesViewController: UIViewController, ImageLoaderDependency, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var imageLoader: ImageLoader!
    var input: Input!
    var output: Output!

    struct Input {
        var images: (_ completion: @escaping (Result<[URL], Error>) -> Void) -> Void
    }

    struct Output {
        var selectImage: (_ url: URL, _ imageView: UIImageView) -> Void
    }

    @IBOutlet private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError("collectionView(collectionView:section:) has not been implemented")
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("collectionView(collectionView:indexPath:) has not been implemented")
    }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return .zero
    }
}
