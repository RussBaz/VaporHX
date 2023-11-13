import Vapor

public struct HXErrorMiddleware: AsyncMiddleware {
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch let error as HXError {
            let headerName = request.application.htmx.errorAttemptCountHeaderName ?? "Attempt"
            switch request.htmx.prefers {
            case .api:
                let retries = UInt(request.headers[headerName].first ?? "") ?? 0
                var abort = error.abort
                abort.headers.replaceOrAdd(name: headerName, value: String(retries))
                throw abort
            case .html:
                let retries = UInt(request.headers[headerName].first ?? "") ?? 0
                let response = try await error.handler(request, error.abort, false)
                response.headers.replaceOrAdd(name: headerName, value: String(retries))
                return response
            case .htmx:
                let retries = UInt(request.headers[headerName].first ?? "") ?? 0
                let response = try await error.handler(request, error.abort, true)
                response.headers.replaceOrAdd(name: headerName, value: String(retries))
                return response
            }
        }
    }

    public init() {}
}
