import Vapor

public struct HXRedirectHeader {
    let location: String

    func serialise() -> String {
        location
    }

    func add(to resp: Response) {
        if !location.isEmpty {
            resp.headers.replaceOrAdd(name: "HX-Redirect", value: serialise())
        }
    }
}
