import Vapor

public struct HXPushUrlHeader {
    public enum HXPushType {
        case enable
        case disable
        case custom(String)
    }
    
    let url: HXPushType
    
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
        resp.headers.replaceOrAdd(name: "HX-Push-Url", value: serialise())
    }
}
