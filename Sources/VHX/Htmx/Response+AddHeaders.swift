import Vapor

public extension Response {
    func add(headers: HXResponseHeaderAddable) -> Self {
        headers.add(to: self)
        return self
    }
}
