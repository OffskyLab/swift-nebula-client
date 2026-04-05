import Foundation
import NIO
import NMTP

// MARK: - Result Types

public struct FindResult: Sendable {
    public let stellarAddress: SocketAddress?
}

public struct UnregisterResult: Sendable {
    public let nextAddress: SocketAddress?
}

// MARK: - IngressClient

/// A typed NMT client connected to an Ingress node.
public struct IngressClient: Sendable {
    public var address: SocketAddress { base.targetAddress }
    internal let base: NMTClient

    private init(base: NMTClient) {
        self.base = base
    }

    public static func connect(
        to address: SocketAddress,
        eventLoopGroup: MultiThreadedEventLoopGroup? = nil
    ) async throws -> IngressClient {
        let base = try await NMTClient.connect(to: address, eventLoopGroup: eventLoopGroup)
        return IngressClient(base: base)
    }

    public var pushes: AsyncStream<Matter> { base.pushes }

    public func close() async throws { try await base.close() }

    public func find(namespace: String) async throws -> FindResult {
        let body = FindBody(namespace: namespace)
        let matter = try Matter.make(type: .find, body: body)
        let reply = try await base.request(matter: matter)
        let replyBody = try reply.decodeBody(FindReplyBody.self)
        let stellarAddress: SocketAddress? = try {
            guard let host = replyBody.stellarHost, let port = replyBody.stellarPort else { return nil }
            return try SocketAddress.makeAddressResolvingHost(host, port: port)
        }()
        return FindResult(stellarAddress: stellarAddress)
    }

    public func enqueue(
        namespace: String,
        service: String,
        method: String,
        arguments: [Argument] = []
    ) async throws {
        let body = EnqueueBody(
            namespace: namespace,
            service: service,
            method: method,
            arguments: arguments.toEncoded()
        )
        let matter = try Matter.make(type: .enqueue, body: body)
        let reply = try await base.request(matter: matter)
        let replyBody = try reply.decodeBody(RegisterReplyBody.self)
        guard replyBody.status == "queued" else {
            throw NebulaClientError.fail(message: "Enqueue failed: \(replyBody.status)")
        }
    }

    public func findGalaxy(topic: String) async throws -> SocketAddress? {
        let body = FindGalaxyBody(topic: topic)
        let matter = try Matter.make(type: .findGalaxy, body: body)
        let reply = try await base.request(matter: matter)
        let replyBody = try reply.decodeBody(FindGalaxyReplyBody.self)
        guard let host = replyBody.galaxyHost, let port = replyBody.galaxyPort else { return nil }
        return try SocketAddress.makeAddressResolvingHost(host, port: port)
    }

    public func unregister(namespace: String, host: String, port: Int) async throws -> UnregisterResult {
        let body = UnregisterBody(namespace: namespace, host: host, port: port)
        let matter = try Matter.make(type: .unregister, body: body)
        let reply = try await base.request(matter: matter)
        let replyBody = try reply.decodeBody(UnregisterReplyBody.self)
        let nextAddress: SocketAddress? = try {
            guard let host = replyBody.nextHost, let port = replyBody.nextPort else { return nil }
            return try SocketAddress.makeAddressResolvingHost(host, port: port)
        }()
        return UnregisterResult(nextAddress: nextAddress)
    }
}

// MARK: - GalaxyClient

/// A typed NMT client connected to a Galaxy node.
public struct GalaxyClient: Sendable {
    public var address: SocketAddress { base.targetAddress }
    internal let base: NMTClient

    private init(base: NMTClient) {
        self.base = base
    }

    public static func connect(
        to address: SocketAddress,
        eventLoopGroup: MultiThreadedEventLoopGroup? = nil
    ) async throws -> GalaxyClient {
        let base = try await NMTClient.connect(to: address, eventLoopGroup: eventLoopGroup)
        return GalaxyClient(base: base)
    }

    public var pushes: AsyncStream<Matter> { base.pushes }

    public func close() async throws { try await base.close() }

    public func request(matter: Matter) async throws -> Matter {
        try await base.request(matter: matter)
    }
}

// MARK: - StellarClient

/// A typed NMT client connected to a Stellar node.
public struct StellarClient: Sendable {
    public var address: SocketAddress { base.targetAddress }
    internal let base: NMTClient

    private init(base: NMTClient) {
        self.base = base
    }

    public static func connect(
        to address: SocketAddress,
        eventLoopGroup: MultiThreadedEventLoopGroup? = nil
    ) async throws -> StellarClient {
        let base = try await NMTClient.connect(to: address, eventLoopGroup: eventLoopGroup)
        return StellarClient(base: base)
    }

    public func request(matter: Matter) async throws -> Matter {
        try await base.request(matter: matter)
    }

    public func close() async throws { try await base.close() }
}
