//
// GalleryBasePreviewCollectionCell
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

open class GalleryBasePreviewCollectionCell: UICollectionViewCell {
    public static let id: Reusable<GalleryBasePreviewCollectionCell> = .fromClass()

    public private(set) var item: GalleryMedia?

    open func set(item: GalleryMedia, setup: ((GalleryBasePreviewCollectionCell) -> Void)?) {
        self.item = item
    }

    open override func prepareForReuse() {
        super.prepareForReuse()

        item = nil
    }
}
