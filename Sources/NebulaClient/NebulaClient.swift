import Foundation
import NIO
import NMTP

/// High-level facade for creating client-side Nebula entities.
public final class NebulaClient: Sendable {

    public static let standard: NebulaClient = NebulaClient()

    private init() {}
}

// MARK: - Client Helpers

extension NebulaClient {

    /// Create a `RoguePlanet` connected to an Ingress via a connection URI.
    ///
    /// URI format: `nmtp://host:port/galaxy/amas/stellar`
    public static func planet(
        connecting uriString: String,
        service: String,
        eventLoopGroup: MultiThreadedEventLoopGroup? = nil
    ) async throws -> RoguePlanet {
        let uri = try NebulaURI(uriString)
        let ingressAddress = try SocketAddress.makeAddressResolvingHost(
            uri.ingressHost, port: uri.ingressPort
        )
        let client = try await IngressClient.connect(
            to: ingressAddress,
            eventLoopGroup: eventLoopGroup
        )
        return RoguePlanet(
            ingressClient: client,
            identifier: UUID(),
            namespace: uri.namespace,
            service: service
        )
    }

    /// Create a `Moon` typed proxy connected to an Ingress via a connection URI.
    public static func moon(
        connecting uriString: String,
        service: String,
        eventLoopGroup: MultiThreadedEventLoopGroup? = nil
    ) async throws -> Moon {
        let planet = try await Self.planet(
            connecting: uriString,
            service: service,
            eventLoopGroup: eventLoopGroup
        )
        return Moon(planet: planet)
    }

    /// Create a `Comet` producer connected to an Ingress via a connection URI.
    public static func comet(
        connecting uriString: String,
        eventLoopGroup: MultiThreadedEventLoopGroup? = nil
    ) async throws -> Comet {
        let uri = try NebulaURI(uriString)
        let ingressAddress = try SocketAddress.makeAddressResolvingHost(
            uri.ingressHost, port: uri.ingressPort
        )
        let client = try await IngressClient.connect(
            to: ingressAddress,
            eventLoopGroup: eventLoopGroup
        )
        return Comet(ingressClient: client, namespace: uri.namespace)
    }
}
