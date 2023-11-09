import Vapor

public struct HXRetargetHeader {
    public let value: String

    public func serialise() -> String {
        value
    }

    public func add(to resp: Response) {
        if !value.isEmpty {
            resp.headers.replaceOrAdd(name: "HX-Retarget", value: serialise())
        }
    }
}
