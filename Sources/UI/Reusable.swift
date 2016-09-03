//
// Reusable
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

import UIKit

public enum Reusable<CellType> {
    case Class(id: String)
    case Nib(id: String, name: String, bundle: NSBundle?)

    public var id: String {
        switch self {
            case .Class(let id): return id
            case .Nib(let id, _, _): return id
        }
    }
}

public extension UITableView {
    // Cell

    public func registerReusableCell<CellType: UITableViewCell>(reusable: Reusable<CellType>) {
        switch reusable {
            case .Class(let id):
                registerClass(CellType.self, forCellReuseIdentifier: id)
            case .Nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                registerNib(nib, forCellReuseIdentifier: id)
        }
    }

    public func dequeueReusableCell<CellType: UITableViewCell>(reusable: Reusable<CellType>, indexPath: NSIndexPath) -> CellType {
        return dequeueReusableCellWithIdentifier(reusable.id, forIndexPath: indexPath) as! CellType
    }

    // Header/Footer

    public func registerReusableHeaderFooter<CellType: UITableViewHeaderFooterView>(reusable: Reusable<CellType>) {
        switch reusable {
            case .Class(let id):
                registerClass(CellType.self, forHeaderFooterViewReuseIdentifier: id)
            case .Nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                registerNib(nib, forHeaderFooterViewReuseIdentifier: id)
        }
    }

    public func dequeueReusableHeaderFooter<CellType: UITableViewHeaderFooterView>(reusable: Reusable<CellType>) -> CellType {
        return dequeueReusableHeaderFooterViewWithIdentifier(reusable.id) as! CellType
    }
}

public extension UICollectionView {
    public func registerReusableCell<CellType: UICollectionViewCell>(reusable: Reusable<CellType>) {
        switch reusable {
            case .Class(let id):
                registerClass(CellType.self, forCellWithReuseIdentifier: id)
            case .Nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                registerNib(nib, forCellWithReuseIdentifier: id)
            }
    }

    public func dequeueReusableCell<CellType: UICollectionViewCell>(reusable: Reusable<CellType>, indexPath: NSIndexPath) -> CellType {
        return dequeueReusableCellWithReuseIdentifier(reusable.id, forIndexPath: indexPath) as! CellType
    }
}
