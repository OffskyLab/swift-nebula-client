import Foundation
import NMTP

/// A proxy for a single named method on a remote service.
///
/// Obtained via `Moon`'s dynamic member lookup. Callable with keyword arguments
/// via `@dynamicCallable`. Returns `Data?` by default; use `call(as:_:)` for
/// typed decoding.
@dynamicCallable
public struct MethodProxy: Sendable {
    public let planet: RoguePlanet
    public let method: String

    public init(planet: RoguePlanet, method: String) {
        self.planet = planet
        self.method = method
    }
}

// MARK: - dynamicCallable

extension MethodProxy {

    @discardableResult
    public func dynamicallyCall(
        withKeywordArguments args: KeyValuePairs<String, ArgumentValue>
    ) async throws -> Data? {
        let arguments = try args.map { key, value in
            try Argument.wrap(key: key, value: value)
        }
        return try await planet.call(method: method, arguments: arguments)
    }
}

// MARK: - Typed call

extension MethodProxy {

    public func call<T: Decodable & Sendable>(
        as type: T.Type,
        _ args: KeyValuePairs<String, ArgumentValue> = [:]
    ) async throws -> T {
        let arguments = try args.map { key, value in
            try Argument.wrap(key: key, value: value)
        }
        return try await planet.call(method: method, arguments: arguments, as: type)
    }
}
