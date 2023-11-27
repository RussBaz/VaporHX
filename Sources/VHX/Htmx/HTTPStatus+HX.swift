import Vapor

public extension HTTPStatus {
    struct HTTPStatusContext {
        let status: HTTPStatus
    }

    func hx(template name: String? = nil, page: Bool? = nil, headers: HXResponseHeaders? = nil) -> HX<HTTPStatusContext> {
        .init(context: HTTPStatusContext(status: self), template: name, page: page, htmxHeaders: headers)
    }
}

extension HTTPStatus.HTTPStatusContext: Encodable {}
extension HTTPStatus.HTTPStatusContext: AsyncResponseEncodable {
    public func encodeResponse(for request: Request) async throws -> Response {
        try await status.encodeResponse(for: request)
    }
}
