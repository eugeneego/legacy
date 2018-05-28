//
// Transformer
// Legacy
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/legacy/blob/master/LICENSE
//

public indirect enum TransformerError: Error {
    case source
    case requirement
    case transform
    case validation(Error)
    case multiple([(String, TransformerError)])
}

public typealias TransformerResult<T> = Result<T, TransformerError>
public typealias TransformerValidator<T> = (T) -> Error?

public protocol Transformer {
    associatedtype Source
    associatedtype Destination

    func transform(source value: Source) -> TransformerResult<Destination>
    func transform(destination value: Destination) -> TransformerResult<Source>
}
