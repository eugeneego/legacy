//
// Result
// EE Utilities
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public enum Result<T, E> {
    case success(T)
    case failure(E)

    // MARK: - Constructors

    public init(value: T) {
        self = .success(value)
    }

    public init(error: E) {
        self = .failure(error)
    }

    public init(try f: () throws -> T) {
        do {
            self = .success(try f())
        } catch let error as E {
            self = .failure(error)
        } catch {
            fatalError("Error type mismatch. Expected \(E.self), but given \(type(of: error))")
        }
    }

    // MARK: - Accessors

    public var value: T? {
        return map(success: { $0 }, failure: { _ in nil })
    }

    public var error: E? {
        return map(success: { _ in nil }, failure: { $0 })
    }

    // MARK: - Map

    public func map<R>(success: (T) -> R, failure: (E) -> R) -> R {
        switch self {
            case .success(let value):
                return success(value)
            case .failure(let error):
                return failure(error)
        }
    }

    public func map<U>(_ transform: (T) -> U) -> Result<U, E> {
        return flatMap { .success(transform($0)) }
    }

    public func flatMap<U>(_ transform: (T) -> Result<U, E>) -> Result<U, E> {
        return map(success: transform, failure: Result<U, E>.failure)
    }

    public func mapError<E2>(_ transform: (E) -> E2) -> Result<T, E2> {
        return flatMapError { .failure(transform($0)) }
    }

    public func flatMapError<E2>(_ transform: (E) -> Result<T, E2>) -> Result<T, E2> {
        return map(success: Result<T, E2>.success, failure: transform)
    }

    // MARK: - Try

    public func `try`() throws -> T {
        switch self {
            case .success(let value):
                return value
            case .failure(let error as Error):
                throw error
            default:
                fatalError("\(E.self) should adopt Error.")
        }
    }

    public func tryMap<U>(_ transform: (T) throws -> U) -> Result<U, E> {
        return flatMap { value in
            Result<U, E>(try: {
                try transform(value)
            })
        }
    }

    // MARK: - Recover

    public func recover(_ value: @autoclosure () -> T) -> T {
        return self.value ?? value()
    }

    public func recover(_ result: @autoclosure () -> Result<T, E>) -> Result<T, E> {
        return map(success: { _ in self }, failure: { _ in result() })
    }

    // MARK: - Description

    public var description: String {
        return map(success: { ".success(\($0))" }, failure: { ".failure(\($0))" })
    }
}

// MARK: - Equatable

public func == <T: Equatable, E: Equatable> (left: Result<T, E>, right: Result<T, E>) -> Bool {
    if let left = left.value, let right = right.value {
        return left == right
    } else if let left = left.error, let right = right.error {
        return left == right
    }
    return false
}

public func != <T: Equatable, E: Equatable> (left: Result<T, E>, right: Result<T, E>) -> Bool {
    return !(left == right)
}

// MARK: - Recover

public func ?? <T, E> (left: Result<T, E>, right: @autoclosure () -> T) -> T {
    return left.recover(right())
}

public func ?? <T, E> (left: Result<T, E>, right: @autoclosure () -> Result<T, E>) -> Result<T, E> {
    return left.recover(right())
}
