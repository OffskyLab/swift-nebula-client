import NMTP

/// A typed proxy over a `RoguePlanet` that enables dynamic method call syntax.
///
/// Obtain via `NebulaClient.moon(connecting:service:)`. Any member access returns a
/// ``MethodProxy`` for that method name, which is directly callable with
/// keyword arguments.
///
/// ```swift
/// let moon = try await NebulaClient.moon(connecting: "nmtp://localhost:6224/prod/ml", service: "wordVectors")
///
/// // Raw result (Data?)
/// let data = try await moon.embed(word: "hello")
///
/// // Typed result
/// let result: EmbeddingResult = try await moon.embed.call(as: EmbeddingResult.self, word: "hello")
/// ```
@dynamicMemberLookup
public final class Moon: Satellite {

    public let planet: RoguePlanet

    public init(planet: RoguePlanet) {
        self.planet = planet
    }

    public subscript(dynamicMember method: String) -> MethodProxy {
        MethodProxy(planet: planet, method: method)
    }
}
