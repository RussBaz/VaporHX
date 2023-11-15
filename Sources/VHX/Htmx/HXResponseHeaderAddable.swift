import Vapor

public protocol HXResponseHeaderAddable {
    func add(to resp: Response)
}
