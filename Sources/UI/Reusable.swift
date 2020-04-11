//
// Reusable
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

#if canImport(UIKit)

#if !os(watchOS)

import UIKit

public enum Reusable<CellType> {
    case `class`(id: String)
    case nib(id: String, name: String, bundle: Bundle?)

    public var id: String {
        switch self {
            case .class(let id), .nib(let id, _, _):
                return id
        }
    }

    public static func fromClass<CellType>(id: String = String(describing: CellType.self)) -> Reusable<CellType> {
        .class(id: id)
    }

    public static func fromNib(
        id: String = String(describing: CellType.self),
        name: String = String(describing: CellType.self),
        bundle: Bundle? = nil
    ) -> Reusable<CellType> {
        .nib(id: id, name: name, bundle: bundle)
    }
}

public extension UITableView {
    // Cell

    func registerReusableCell<CellType: UITableViewCell>(_ reusable: Reusable<CellType>) {
        switch reusable {
            case .class(let id):
                register(CellType.self, forCellReuseIdentifier: id)
            case .nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                register(nib, forCellReuseIdentifier: id)
        }
    }

    func dequeueReusableCell<CellType: UITableViewCell>(_ reusable: Reusable<CellType>) -> CellType {
        let anyCell = dequeueReusableCell(withIdentifier: reusable.id)
        guard let cell = anyCell as? CellType else {
            fatalError("Invalid table view cell type. Expected \(CellType.self), but received \(type(of: anyCell))")
        }
        return cell
    }

    func dequeueReusableCell<CellType: UITableViewCell>(_ reusable: Reusable<CellType>, indexPath: IndexPath) -> CellType {
        let anyCell = dequeueReusableCell(withIdentifier: reusable.id, for: indexPath)
        guard let cell = anyCell as? CellType else {
            fatalError("Invalid table view cell type. Expected \(CellType.self), but received \(type(of: anyCell))")
        }
        return cell
    }

    // Header/Footer

    func registerReusableHeaderFooter<CellType: UITableViewHeaderFooterView>(_ reusable: Reusable<CellType>) {
        switch reusable {
            case .class(let id):
                register(CellType.self, forHeaderFooterViewReuseIdentifier: id)
            case .nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                register(nib, forHeaderFooterViewReuseIdentifier: id)
        }
    }

    func dequeueReusableHeaderFooter<CellType: UITableViewHeaderFooterView>(_ reusable: Reusable<CellType>) -> CellType {
        let anyCell = dequeueReusableHeaderFooterView(withIdentifier: reusable.id)
        guard let cell = anyCell as? CellType else {
            fatalError("Invalid table view header/footer type. Expected \(CellType.self), but received \(type(of: anyCell))")
        }
        return cell
    }
}

public extension UICollectionView {
    func registerReusableCell<CellType: UICollectionViewCell>(_ reusable: Reusable<CellType>) {
        switch reusable {
            case .class(let id):
                register(CellType.self, forCellWithReuseIdentifier: id)
            case .nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                register(nib, forCellWithReuseIdentifier: id)
            }
    }

    func registerReusableSupplementaryView<CellType: UICollectionReusableView>(_ reusable: Reusable<CellType>, kind: String) {
        switch reusable {
            case .class(let id):
                register(CellType.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: id)
            case .nib(let id, let name, let bundle):
                let nib = UINib(nibName: name, bundle: bundle)
                register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: id)
            }
    }

    func dequeueReusableCell<CellType: UICollectionViewCell>(_ reusable: Reusable<CellType>, indexPath: IndexPath) -> CellType {
        let anyCell = dequeueReusableCell(withReuseIdentifier: reusable.id, for: indexPath)
        guard let cell = anyCell as? CellType else {
            fatalError("Invalid collection view cell type. Expected \(CellType.self), but received \(type(of: anyCell))")
        }
        return cell
    }

    func dequeueReusableSupplementaryView<CellType: UICollectionReusableView>(
        _ reusable: Reusable<CellType>,
        indexPath: IndexPath,
        kind: String
    ) -> CellType {
        let anyCell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reusable.id, for: indexPath)
        guard let cell = anyCell as? CellType else {
            fatalError("Invalid collection view supplementary view type. Expected \(CellType.self), but received \(type(of: anyCell))")
        }
        return cell
    }
}

#endif

#endif
