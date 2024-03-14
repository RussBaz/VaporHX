import Vapor

extension [HXResponseHeaderAddable]: HXResponseHeaderAddable {
    public func add(to resp: Response) {
        for i in self {
            i.add(to: resp)
        }
    }
}
