import Testing
import Foundation
import NIO
import NMTP
@testable import NebulaClient

// These integration tests require a running Ingress+Galaxy+Stellar stack.
// The tests below focus on URI parsing and typed-client construction (unit tests).

@Suite("NebulaURI")
struct NebulaURITests {

    @Test func parse_validURI() throws {
        let uri = try NebulaURI("nmtp://localhost:6224/production/ml/embedding")
        #expect(uri.ingressHost == "localhost")
        #expect(uri.ingressPort == 6224)
        #expect(uri.namespace == "production.ml.embedding")
        #expect(uri.galaxyName == "production")
    }

    @Test func parse_ipv6URI() throws {
        let uri = try NebulaURI("nmtp://[::1]:6224/prod/svc")
        #expect(uri.ingressHost == "::1")
        #expect(uri.ingressPort == 6224)
        #expect(uri.namespace == "prod.svc")
    }

    @Test func parse_invalidScheme_throws() throws {
        #expect(throws: NebulaClientError.self) {
            try NebulaURI("http://localhost:6224/prod")
        }
    }

    @Test func parse_missingPort_throws() throws {
        #expect(throws: NebulaClientError.self) {
            try NebulaURI("nmtp://localhost/prod")
        }
    }

    @Test func parse_missingNamespace_throws() throws {
        #expect(throws: NebulaClientError.self) {
            try NebulaURI("nmtp://localhost:6224/")
        }
    }
}
