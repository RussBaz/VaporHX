import Vapor

public extension Request {
    var baseUrl: String {
        get throws {
            if application.environment == .production {
                guard let host = Environment.get("PUBLIC_HOST") else {
                    throw Abort(.internalServerError)
                }
                return host
            } else if let host = Environment.get("PUBLIC_HOST") {
                return host
            } else {
                let configuration = application.http.server.configuration
                let scheme = configuration.tlsConfiguration == nil ? "http" : "https"
                let host = configuration.hostname
                let port = configuration.port
                if port == 80 {
                    return "\(scheme)://\(host)"
                } else {
                    return "\(scheme)://\(host):\(port)"
                }
            }
        }
    }
}
