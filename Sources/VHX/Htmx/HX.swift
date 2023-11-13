import Vapor

public struct HX<T: AsyncResponseEncodable & Encodable> {
    public let context: T
    public let template: String?
    public let page: Bool?
    public let htmxHeaders: HXResponseHeaders?

    public init(context: T, template: String?, page: Bool?, htmxHeaders: HXResponseHeaders?) {
        self.context = context
        self.template = template
        self.page = page
        self.htmxHeaders = htmxHeaders
    }
}

extension HX: AsyncResponseEncodable {
    public func encodeResponse(for request: Request) async throws -> Response {
        switch request.htmx.prefers {
        case .api: try await context.encodeResponse(for: request)
        case .htmx: if let template {
                try await request.htmx.render(template, context, page: page ?? false)
            } else {
                Response(status: .noContent)
            }
        case .html: if let template {
                try await request.htmx.render(template, context, page: page ?? true)
            } else {
                Response(status: .noContent)
            }
        }
    }
}
