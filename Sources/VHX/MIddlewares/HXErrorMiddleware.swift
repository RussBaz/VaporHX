import Vapor

public struct HXErrorMiddleware: AsyncMiddleware {
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch let error as HXError {
            switch request.htmx.prefers {
            case .api:
                throw error.abort
            default:
                let retries = UInt(request.headers["Attempt"].first ?? "") ?? 0
                let response = try await error.handler(request, error.abort)
                response.headers.replaceOrAdd(name: "Attempt", value: String(retries))
                return response
            }
        }
    }
}
