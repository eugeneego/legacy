//
// GalleryRoutines
// Legacy
//
// Copyright (c) 2018 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

import UIKit

enum GalleryRoutines {
    static func configureControllerTitle(view: UIView, titleView: UIView, closeButton: UIButton, shareButton: UIButton) {
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        titleView.isUserInteractionEnabled = true
        view.addSubview(titleView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .clear
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        titleView.addSubview(closeButton)

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.backgroundColor = .clear
        shareButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        titleView.addSubview(shareButton)

        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            titleView.heightAnchor.constraint(equalToConstant: topInset + 44),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closeButton.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            closeButton.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            shareButton.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            shareButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            shareButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    static var topInset: CGFloat {
        var topInset: CGFloat = 0
        if #available(iOS 11.0, *) {
            topInset = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
        }
        topInset = max(topInset, 20)
        return topInset
    }
}
