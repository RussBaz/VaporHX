import Vapor

public extension Content where Self: AsyncResponseEncodable & Encodable {
    func hx(template name: String? = nil, page: Bool? = nil, headers: HXResponseHeaders? = nil) -> HX<Self> {
        .init(context: self, template: name, page: page, htmxHeaders: headers)
    }

    func hx<T: HXTemplateable>(template: T.Type, page: Bool? = nil, headers: HXResponseHeaders? = nil) -> HX<Self> where T.Context == Self {
        .init(context: self, template: template, page: page, htmxHeaders: headers)
    }
}
