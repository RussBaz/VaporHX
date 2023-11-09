import Vapor

public struct HXError: Error {
    public let abort: Abort
    public let handler: (_ req: Request, _ abort: Abort) async throws -> Response
}
