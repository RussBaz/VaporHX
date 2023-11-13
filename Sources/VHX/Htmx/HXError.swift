import Vapor

public struct HXError: Error {
    public let abort: Abort
    public let handler: (_ req: Request, _ abort: Abort, _ htmx: Bool) async throws -> Response

    public init(abort: Abort, handler: @escaping (_: Request, _: Abort, _: Bool) async throws -> Response) {
        self.abort = abort
        self.handler = handler
    }
}
