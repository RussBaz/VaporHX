import Vapor

public struct HX<T: AsyncResponseEncodable & Encodable> {
    let context: T
    let template: String?
    let page: Bool?
    let htmxHeaders: HXResponseHeaders?
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
