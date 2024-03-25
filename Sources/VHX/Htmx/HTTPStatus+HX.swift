import Vapor

public extension HTTPStatus {
    struct HTTPStatusContext {
        let status: HTTPStatus
    }

    func hx(template name: String? = nil, page: Bool? = nil, headers: HXResponseHeaders? = nil) -> HX<HTTPStatusContext> {
        .init(context: HTTPStatusContext(status: self), template: name, page: page, htmxHeaders: headers)
    }

    func hx<T: HXTemplateable>(template: T.Type, page: Bool? = nil, headers: HXResponseHeaders? = nil) -> HX<HTTPStatusContext> where T.Context == HTTPStatusContext {
        .init(context: HTTPStatusContext(status: self), template: template, page: page, htmxHeaders: headers)
    }

    func hx<T: HXTemplateable>(template: T.Type, page: Bool? = nil, headers: HXResponseHeaders? = nil) -> HX<EmptyContext> where T.Context == EmptyContext {
        .init(context: EmptyContext(), template: template, page: page, htmxHeaders: headers)
    }
}

extension HTTPStatus.HTTPStatusContext: Encodable {}
extension HTTPStatus.HTTPStatusContext: AsyncResponseEncodable {
    public func encodeResponse(for request: Request) async throws -> Response {
        try await status.encodeResponse(for: request)
    }
}
