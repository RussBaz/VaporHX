import Vapor

public struct HXRefreshHeader {
    let value: Bool
    
    func serialise() -> String {
        if value { "true" } else { "" }
    }
    
    func add(to resp: Response) {
        if value {
            resp.headers.replaceOrAdd(name: "HX-Refresh", value: serialise())
        }
    }
}
