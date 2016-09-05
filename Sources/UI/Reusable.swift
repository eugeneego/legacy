//
// Reusable
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

public enum Reusable<CellType> {
    case `class`(id: String)
    case nib(id: String, name: String, bundle: Bundle?)

    public var id: String {
        switch self {
            case .class(let id): return id
            case .nib(let id, _, _): return id
        }
    }
}

public extension UITableView {
    // Cell

    public func registerReusableCell<CellType: UITableViewCell>(_ reusable: Reusable<CellType>) {
        switch reusable {
            case .class(let id):
                register(CellType.self, forCellReuseIdentifier: id)
            case .nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                register(nib, forCellReuseIdentifier: id)
        }
    }

    public func dequeueReusableCell<CellType: UITableViewCell>(_ reusable: Reusable<CellType>, indexPath: IndexPath) -> CellType {
        return self.dequeueReusableCell(withIdentifier: reusable.id, for: indexPath) as! CellType
    }

    // Header/Footer

    public func registerReusableHeaderFooter<CellType: UITableViewHeaderFooterView>(_ reusable: Reusable<CellType>) {
        switch reusable {
            case .class(let id):
                register(CellType.self, forHeaderFooterViewReuseIdentifier: id)
            case .nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                register(nib, forHeaderFooterViewReuseIdentifier: id)
        }
    }

    public func dequeueReusableHeaderFooter<CellType: UITableViewHeaderFooterView>(_ reusable: Reusable<CellType>) -> CellType {
        return dequeueReusableHeaderFooterView(withIdentifier: reusable.id) as! CellType
    }
}

public extension UICollectionView {
    public func registerReusableCell<CellType: UICollectionViewCell>(_ reusable: Reusable<CellType>) {
        switch reusable {
            case .class(let id):
                register(CellType.self, forCellWithReuseIdentifier: id)
            case .nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                register(nib, forCellWithReuseIdentifier: id)
            }
    }

    public func dequeueReusableCell<CellType: UICollectionViewCell>(_ reusable: Reusable<CellType>, indexPath: IndexPath) -> CellType {
        return self.dequeueReusableCell(withReuseIdentifier: reusable.id, for: indexPath) as! CellType
    }
}
