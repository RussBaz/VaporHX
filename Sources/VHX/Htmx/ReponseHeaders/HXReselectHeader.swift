import Vapor

public struct HXReselectHeader {
    let value: String

    func serialise() -> String {
        value
    }

    func add(to resp: Response) {
        if !value.isEmpty {
            resp.headers.replaceOrAdd(name: "HX-Reselect", value: serialise())
        }
    }
}
