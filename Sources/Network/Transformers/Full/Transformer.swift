//
// Transformer
// EE Utilities
//
// Copyright (c) 2017 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/utilities-ios/blob/master/LICENSE
//

public indirect enum TransformerError: Error {
    case badDictionary
    case requirement
    case transform
    case validation(Error)
    case multiple([(String, TransformerError)])
}

public typealias TransformerResult<T> = Result<T, TransformerError>
public typealias TransformerValidator<T> = (T) -> Error?

public protocol ForwardTransformer {
    associatedtype Source
    associatedtype Destination

    func transform(source value: Source) -> TransformerResult<Destination>
}

public protocol BackwardTransformer {
    associatedtype Source
    associatedtype Destination

    func transform(destination value: Destination) -> TransformerResult<Source>
}

public protocol FullTransformer: ForwardTransformer, BackwardTransformer {}
