/// A typed proxy over a `RoguePlanet`.
///
/// Conforming types wrap a Planet connection and expose remote methods
/// via `@dynamicMemberLookup`. The standard implementation is `Moon`.
public protocol Satellite: Sendable {
    var planet: RoguePlanet { get }
}
