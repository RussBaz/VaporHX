import Vapor

public extension Request {
    var htmx: Htmx {
        .init(req: self)
    }
}
