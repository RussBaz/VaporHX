import Vapor

public struct HXReplaceUrlHeader {
    public enum HXReplaceType {
        case enable
        case disable
        case custom(String)
    }
    
    let url: HXReplaceType
    
    func serialise() -> String {
        switch url {
        case .enable:
            "true"
        case .disable:
            "false"
        case .custom(let custom):
            "\(custom)"
        }
    }
    
    func add(to resp: Response) {
        resp.headers.replaceOrAdd(name: "HX-Replace-Url", value: serialise())
    }
}
