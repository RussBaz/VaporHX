import Vapor

public extension Response {
    @discardableResult
    func add(headers: HXResponseHeaderAddable) -> Self {
        headers.add(to: self)
        return self
    }
}
