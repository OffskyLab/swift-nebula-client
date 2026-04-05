import Foundation
import NIO
import NMTP

/// An async message producer that enqueues tasks into `BrokerAmas` via Ingress.
///
/// Unlike `RoguePlanet` (RPC, waits for result), `Comet` confirms the message is
/// queued and moves on. `BrokerAmas` handles delivery, retry, and parking.
///
/// ```swift
/// let comet = try await NebulaClient.comet(connecting: "nmtp+broker://localhost:6224/production/orders/jobs")
/// try await comet.enqueue(service: "orderService", method: "process", arguments: [...])
/// ```
public actor Comet: Astral {
    public static var category: AstralCategory { .comet }

    public let identifier: UUID
    public let name: String

    private let ingressClient: IngressClient
    private let defaultNamespace: String

    public init(
        ingressClient: IngressClient,
        name: String = "comet",
        namespace: String,
        identifier: UUID = UUID()
    ) {
        self.identifier = identifier
        self.name = name
        self.ingressClient = ingressClient
        self.defaultNamespace = namespace
    }
}

// MARK: - Enqueue

extension Comet {

    /// Enqueue a task. Returns once BrokerAmas confirms receipt ("queued").
    public func enqueue(
        service: String,
        method: String,
        arguments: [Argument] = [],
        namespace: String? = nil
    ) async throws {
        let ns = namespace ?? defaultNamespace
        try await ingressClient.enqueue(
            namespace: ns,
            service: service,
            method: method,
            arguments: arguments
        )
    }
}
