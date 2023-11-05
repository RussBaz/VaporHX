import Vapor

extension Request {
    var htmx: Htmx {
        .init(req: self)
    }
}
