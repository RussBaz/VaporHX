import Vapor

public extension Request {
    var language: HXRequestLocalisation {
        .init(req: self)
    }
}
