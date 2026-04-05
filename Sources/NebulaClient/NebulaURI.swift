import Foundation

/// Represents an `nmtp://` connection URI used to locate a namespace via Ingress.
///
/// Namespace segments are expressed as path components in forward order:
/// `{galaxy}/{amas}/{stellar}` — broadest first, most specific last.
///
/// ```
/// nmtp://localhost:6224/production/ml/embedding
///        └─────────────┘ └────────┘ └┘ └───────┘
///        Ingress address  galaxy    amas stellar
/// ```
///
/// Path segments are joined with `.` to form the namespace string `production.ml.embedding`.
public struct NebulaURI: Sendable {
    public static let scheme = "nmtp"

    public let user: String?
    public let password: String?

    /// Ingress host address.
    public let ingressHost: String
    /// Ingress port.
    public let ingressPort: Int

    /// The service namespace in forward order (e.g. `production.ml.embedding`).
    public let namespace: String

    /// Galaxy name — first dot-separated segment of namespace.
    public var galaxyName: String {
        String(namespace.split(separator: ".").first ?? Substring(namespace))
    }

    public init(_ string: String) throws {
        guard let components = URLComponents(string: string),
              components.scheme == Self.scheme else {
            throw NebulaClientError.invalidURI("URI must use nmtp:// scheme: \(string)")
        }

        guard let host = components.host, !host.isEmpty else {
            throw NebulaClientError.invalidURI("Missing Ingress host in URI: \(string)")
        }

        guard let port = components.port else {
            throw NebulaClientError.invalidURI("Missing Ingress port in URI: \(string)")
        }

        user     = components.user
        password = components.password

        ingressHost = host.hasPrefix("[") && host.hasSuffix("]")
            ? String(host.dropFirst().dropLast())
            : host
        ingressPort = port

        let pathParts = components.path
            .split(separator: "/", omittingEmptySubsequences: true)
            .map(String.init)

        guard !pathParts.isEmpty else {
            throw NebulaClientError.invalidURI("Missing namespace in URI: \(string)")
        }

        namespace = pathParts.joined(separator: ".")
    }
}
