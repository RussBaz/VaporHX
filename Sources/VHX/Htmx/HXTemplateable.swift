import Vapor

public protocol HXTemplateable {
    associatedtype Context: AsyncResponseEncodable & Encodable

    static func render(req: Request, isPage: Bool, context: Context) -> String
}

public struct EmptyContext: AsyncResponseEncodable, Encodable {
    public init() {}
    public func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
        try await "".encodeResponse(for: request)
    }
}
