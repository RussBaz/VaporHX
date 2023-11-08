import Vapor

public extension Content where Self: AsyncResponseEncodable & Encodable {
    func hx(template name: String? = nil, page: Bool? = nil, headers: HXResponseHeaders? = nil) -> HX<Self> {
        .init(context: self, template: name, page: page, htmxHeaders: headers)
    }
}
