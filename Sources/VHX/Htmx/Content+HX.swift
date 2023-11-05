import Vapor

public extension Content where Self: AsyncResponseEncodable & Encodable {
    func hx(template name: String? = nil, page: Bool? = nil) -> HX<Self> {
        .init(context: self, template: name, page: page)
    }
}
