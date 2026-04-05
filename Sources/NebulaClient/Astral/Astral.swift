import Foundation

/// Astral category constants for the Nebula protocol.
/// Raw values align with the server-side `AstralCategory` spec (must not change).
public enum AstralCategory: UInt8, Sendable {
    case planet    = 1
    case stellar   = 2
    case galaxy    = 8
    case comet     = 3
    case satellite = 4

    public var name: String {
        switch self {
        case .planet:    return "Planet"
        case .stellar:   return "Stellar"
        case .galaxy:    return "Galaxy"
        case .comet:     return "Comet"
        case .satellite: return "Satellite"
        }
    }
}

/// Base protocol for all client-side Astral entities.
public protocol Astral: Sendable {
    static var category: AstralCategory { get }
    var identifier: UUID { get }
    var name: String { get }
    var namespace: String { get }
}

extension Astral {
    public var namespace: String { name }
}
