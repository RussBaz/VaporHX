import Vapor

public struct HXRetargetHeader {
    let value: String
    
    func serialise() -> String {
        value
    }
    
    func add(to resp: Response) {
        if !value.isEmpty {
            resp.headers.replaceOrAdd(name: "HX-Retarget", value: serialise())
        }
    }
}
