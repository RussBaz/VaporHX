import Vapor

public struct HXError: Error {
    let abort: Abort
    let handler: (_ req: Request, _ abort: Abort) async throws -> Response
}
