import Vapor

public extension HTTPStatus {
    func hx(template name: String? = nil, page: Bool? = nil, headers: HXResponseHeaders? = nil) -> HX<Self> {
        .init(context: self, template: name, page: page, htmxHeaders: headers)
    }
}
