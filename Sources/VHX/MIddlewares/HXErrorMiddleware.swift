import Vapor

struct HXErrorMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch let error as HXError {
            return switch request.htmx.prefers {
            case .api:
                throw error.abort
            default:
                try await error.handler(request, error.abort)
            }
        }
    }
}
