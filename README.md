# swift-nebula-client

> [!WARNING]
> This package is in early development. Many features are not yet implemented and the API is subject to breaking changes. Do not use in production.

Swift client SDK for the [Nebula](https://github.com/gradyzhuo/swift-nebula) distributed RPC framework, built on [swift-nmtp](https://github.com/gradyzhuo/swift-nmtp).

---

## Overview

`swift-nebula-client` provides the client-side entities for connecting to a Nebula network:

| Type | Role |
|------|------|
| `RoguePlanet` | RPC client — calls remote service methods and waits for results |
| `Comet` | Async producer — enqueues tasks into a broker namespace |
| `Subscriber` | Pub-sub consumer — receives events pushed from Galaxy |
| `Moon` | Typed proxy over `RoguePlanet` with dynamic method call syntax |

Connection to the network always starts via **Ingress**, which handles service discovery and routing to the appropriate Stellar node.

---

## Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/gradyzhuo/swift-nebula-client.git", from: "0.1.0"),
],
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "NebulaClient", package: "swift-nebula-client"),
    ]),
]
```

---

## Usage

### RPC — RoguePlanet

Connect to Ingress and call a remote method directly:

```swift
import NebulaClient

let planet = try await NebulaClient.planet(
    connecting: "nmtp://localhost:6224/production/ml/embedding",
    service: "w2v"
)

// Raw call — returns Data?
let data = try await planet.call(method: "wordVector", arguments: [
    .wrap(key: "word", value: "hello")
])

// Typed call
struct VectorResult: Decodable { let vector: [Float] }
let result = try await planet.call(method: "wordVector", as: VectorResult.self)
```

### RPC — Moon (dynamic syntax)

`Moon` wraps a `RoguePlanet` and lets you call methods like function calls:

```swift
import NebulaClient

let moon = try await NebulaClient.moon(
    connecting: "nmtp://localhost:6224/production/ml/embedding",
    service: "w2v"
)

// Dynamic call — returns Data?
let data = try await moon.wordVector(word: "hello")

// Typed call
let result: VectorResult = try await moon.wordVector.call(as: VectorResult.self, word: "hello")
```

### Async Messaging — Comet

Enqueue tasks into a broker namespace without waiting for the result:

```swift
import NebulaClient

let comet = try await NebulaClient.comet(
    connecting: "nmtp://localhost:6224/production/orders"
)

try await comet.enqueue(
    service: "orderService",
    method: "process",
    arguments: [
        .wrap(key: "orderID", value: "ORD-1001"),
        .wrap(key: "amount",  value: 49.99),
    ]
)
```

### Pub-Sub — Subscriber

Subscribe to a broker topic and receive events pushed from Galaxy:

```swift
import NebulaClient
import NIO

let ingressAddress = try SocketAddress.makeAddressResolvingHost("127.0.0.1", port: 6224)
let ingressClient = try await IngressClient.connect(to: ingressAddress)

let subscriber = try await Subscriber(
    ingressClient: ingressClient,
    topic: "production.orders",
    subscription: "fulfillment"
)

for await event in await subscriber.events {
    print("\(event.service).\(event.method)", event.arguments.toArguments().toDictionary())
}
```

---

## Connection Model

```
RoguePlanet / Comet / Subscriber
        │
        ▼
    IngressClient  ──── find(namespace:) ────▶  Galaxy
        │                                          │
        │◀──── stellarAddress ─────────────────────┘
        │
        ▼
    StellarClient  ──── call / enqueue ────▶  Stellar
```

- **Normal path**: connect to Ingress → get Stellar address → call Stellar directly
- **Failover**: Stellar unreachable → notify Ingress → get next Stellar → reconnect

---

## Relationship to Nebula

```
swift-nmtp          ← transport protocol layer
    ↓
swift-nebula        ← server framework (Galaxy, Stellar, Ingress)
    ↓
swift-nebula-client ← this repo — Swift client SDK
```

`swift-nebula-client` only depends on `swift-nmtp`. It has no dependency on `swift-nebula`, allowing the client to stay lightweight and enabling other language SDKs to implement the same protocol independently.

---

## Requirements

- Swift 6.0+
- macOS 13+

## Dependencies

- [gradyzhuo/swift-nmtp](https://github.com/gradyzhuo/swift-nmtp)
- [apple/swift-nio](https://github.com/apple/swift-nio)
- [hirotakan/MessagePacker](https://github.com/hirotakan/MessagePacker)
- [apple/swift-log](https://github.com/apple/swift-log)

## License

Apache License 2.0
