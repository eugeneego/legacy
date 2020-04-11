//
// Result
// Legacy
//
// Copyright (c) 2016 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public extension Result {
    // MARK: - Initializers

    init(value: Success) {
        self = .success(value)
    }

    init(error: Failure) {
        self = .failure(error)
    }

    init(_ value: Success?, _ error: @autoclosure () -> Failure) {
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(error())
        }
    }

    // MARK: - Accessors

    var value: Success? {
        map(success: { $0 }, failure: { _ in nil })
    }

    var error: Failure? {
        map(success: { _ in nil }, failure: { $0 })
    }

    // MARK: - Map

    func map<NewResult>(success: (Success) -> NewResult, failure: (Failure) -> NewResult) -> NewResult {
        switch self {
            case .success(let value):
                return success(value)
            case .failure(let error):
                return failure(error)
        }
    }

    // MARK: - Try

    static func typeMismatchFatalError(_ error: Error) -> Failure {
        fatalError("Error type mismatch. Expected \(Failure.self), but given \(type(of: error))")
    }

    init(catching body: () throws -> Success, unknown: (Error) -> Failure) {
        do {
            self = .success(try body())
        } catch let error as Failure {
            self = .failure(error)
        } catch {
            self = .failure(unknown(error))
        }
    }

    func tryMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess, unknown: (Error) -> Failure) -> Result<NewSuccess, Failure> {
        flatMap { value in
            Result<NewSuccess, Failure>(
                catching: {
                    try transform(value)
                },
                unknown: unknown
            )
        }
    }
}
