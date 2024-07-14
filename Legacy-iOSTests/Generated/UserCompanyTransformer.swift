// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct UserCompanyTransformer: Transformer {
    typealias Source = Any
    typealias Destination = User.Company

    let nameName = "name"
    let catchPhraseName = "catchPhrase"
    let bsName = "bs"

    let nameTransformer = CastTransformer<Any, String>()
    let catchPhraseTransformer = CastTransformer<Any, String>()
    let bsTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let nameResult = dictionary[nameName].map(nameTransformer.transform(source:)) ?? .failure(.requirement)
        let catchPhraseResult = dictionary[catchPhraseName].map(catchPhraseTransformer.transform(source:)) ?? .failure(.requirement)
        let bsResult = dictionary[bsName].map(bsTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        nameResult.error.map { errors.append((nameName, $0)) }
        catchPhraseResult.error.map { errors.append((catchPhraseName, $0)) }
        bsResult.error.map { errors.append((bsName, $0)) }

        guard
            let name = nameResult.value,
            let catchPhrase = catchPhraseResult.value,
            let bs = bsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                name: name,
                catchPhrase: catchPhrase,
                bs: bs
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let nameResult = nameTransformer.transform(destination: value.name)
        let catchPhraseResult = catchPhraseTransformer.transform(destination: value.catchPhrase)
        let bsResult = bsTransformer.transform(destination: value.bs)

        var errors: [(String, TransformerError)] = []
        nameResult.error.map { errors.append((nameName, $0)) }
        catchPhraseResult.error.map { errors.append((catchPhraseName, $0)) }
        bsResult.error.map { errors.append((bsName, $0)) }

        guard
            let name = nameResult.value,
            let catchPhrase = catchPhraseResult.value,
            let bs = bsResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[nameName] = name
        dictionary[catchPhraseName] = catchPhrase
        dictionary[bsName] = bs
        return .success(dictionary)
    }
}
// swiftlint:enable all
