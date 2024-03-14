import Vapor

public extension Request {
    struct HtmxStorageKey: StorageKey {
        public typealias Value = Htmx
    }

    var htmx: Htmx {
        get {
            if let htmx = storage[HtmxStorageKey.self] {
                return htmx
            } else {
                let htmx = Htmx(req: self, response: HXResponseConfiguration())
                storage[HtmxStorageKey.self] = htmx
                return htmx
            }
        }
        set {
            if storage[HtmxStorageKey.self] == nil {
                storage[HtmxStorageKey.self] = newValue
            } else {
                fatalError("Redeclaration of HTMX service")
            }
        }
    }
}
