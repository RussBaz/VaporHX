import Vapor

public extension HTTPHeaders {
    var htmx: HXRequestHeaders {
        .init(headers: self)
    }
}
