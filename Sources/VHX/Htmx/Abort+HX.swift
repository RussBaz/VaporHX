import Vapor

public extension Abort {
    func hx() -> HXError {
        let using = { (req: Request, abort: Self, htmx: Bool) async throws in
            let status: HTTPStatus = if htmx { .noContent } else { abort.status }
            let response = try await status.encodeResponse(for: req)
            response.headers = abort.headers
            return response
        }
        return .init(abort: self, handler: using)
    }

    func hx(_ using: @escaping (_ req: Request, _ abort: Abort, _ htmx: Bool) async throws -> Response) -> HXError {
        .init(abort: self, handler: using)
    }
}
