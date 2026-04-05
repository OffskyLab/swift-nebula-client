import Foundation

public enum NebulaClientError: Error {
    case fail(message: String)
    case serviceNotFound(namespace: String)
    case connectionClosed
    case invalidURI(_ reason: String)
}
