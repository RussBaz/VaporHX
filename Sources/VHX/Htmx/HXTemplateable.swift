import Vapor

public protocol HXTemplateable {
    associatedtype Context: AsyncResponseEncodable & Encodable

    static func render(req: Request, context: Context, isPage: Bool) -> String
}

public struct EmptyContext: AsyncResponseEncodable, Encodable {
    public func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
        try await "".encodeResponse(for: request)
    }
}
