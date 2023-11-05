import Vapor

public extension HTTPStatus {
    func hx(template name: String? = nil, page: Bool? = nil) -> HX<Self> {
        .init(context: self, template: name, page: page)
    }
}
