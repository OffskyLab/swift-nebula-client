import Foundation
import NIO
import NMTP

/// A broker subscriber that receives async events pushed from `BrokerAmas` via Galaxy.
///
/// Discovers the Galaxy address via Ingress (`findGalaxy`), connects directly,
/// and joins a subscription group. Incoming events arrive via `events`.
///
/// ```swift
/// let subscriber = try await Subscriber(
///     ingressClient: ingressClient,
///     topic: "production.orders",
///     subscription: "fulfillment"
/// )
/// for await event in subscriber.events {
///     try await handleOrder(event)
/// }
/// ```
public actor Subscriber {
    public let topic: String
    public let subscription: String

    /// Server-pushed events from Galaxy's `BrokerAmas`.
    public let events: AsyncStream<EnqueueBody>

    private let galaxyClient: GalaxyClient
    private let eventContinuation: AsyncStream<EnqueueBody>.Continuation

    public init(
        ingressClient: IngressClient,
        topic: String,
        subscription: String
    ) async throws {
        self.topic = topic
        self.subscription = subscription

        guard let galaxyAddress = try await ingressClient.findGalaxy(topic: topic) else {
            throw NebulaClientError.fail(message: "No Galaxy found for broker topic: \(topic)")
        }

        let client = try await GalaxyClient.connect(to: galaxyAddress)
        self.galaxyClient = client

        var cont: AsyncStream<EnqueueBody>.Continuation!
        self.events = AsyncStream { cont = $0 }
        self.eventContinuation = cont

        let body = SubscribeBody(topic: topic, subscription: subscription)
        let matter = try Matter.make(type: .subscribe, body: body)
        _ = try await client.request(matter: matter)

        Task {
            for await pushed in client.pushes {
                guard pushed.type == .enqueue,
                      let body = try? pushed.decodeBody(EnqueueBody.self)
                else { continue }
                cont.yield(body)
            }
        }
    }
}
