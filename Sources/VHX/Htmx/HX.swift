import Vapor

public struct HX<T: AsyncResponseEncodable & Encodable> {
    public typealias TemplateRenderer = (_ req: Request, _ context: T, _ page: Bool?, _ headers: HXResponseHeaders?) async throws -> Response

    public let context: T
    public let template: TemplateRenderer?
    public let page: Bool?
    public let htmxHeaders: HXResponseHeaders?

    public init(context: T, template name: String?, page: Bool?, htmxHeaders: HXResponseHeaders?) {
        self.context = context

        if let name {
            template = { req, context, page, headers in
                try await req.htmx.render(name, context, page: page, headers: htmxHeaders)
            }
        } else {
            template = nil
        }

        self.page = page
        self.htmxHeaders = htmxHeaders
    }

    public init<U: HXTemplateable>(context: T, template: U.Type, page: Bool?, htmxHeaders: HXResponseHeaders?) where U.Context == T {
        self.context = context

        self.template = { req, context, page, headers in
            try await req.htmx.render(template, context, page: page, headers: htmxHeaders)
        }

        self.page = page
        self.htmxHeaders = htmxHeaders
    }
}

extension HX: AsyncResponseEncodable {
    public func encodeResponse(for request: Request) async throws -> Response {
        switch request.htmx.prefers {
        case .api: try await context.encodeResponse(for: request)
        case .htmx: if let template {
                try await template(request, context, page, htmxHeaders)
            } else {
                if let htmxHeaders {
                    Response(status: .noContent).add(headers: htmxHeaders)
                } else {
                    Response(status: .noContent)
                }
            }
        case .html: if let template {
                try await template(request, context, page, nil)
            } else {
                Response(status: .noContent)
            }
        }
    }
}
