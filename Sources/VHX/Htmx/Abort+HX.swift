import Vapor

public extension Abort {
    func hx() -> HXError {
        let using = { (_: Request, abort: Self) async throws in
            let response = Response(status: .noContent)
            response.headers = abort.headers
            return response
        }
        return .init(abort: self, handler: using)
    }

    func hx(_ using: @escaping (_ req: Request, _ abort: Abort) -> Response) async throws -> HXError {
        .init(abort: self, handler: using)
    }
}
