import Vapor

public extension Application {
    struct HtmxStorageKey: StorageKey {
        public typealias Value = HtmxConfiguration
    }

    var htmx: HtmxConfiguration {
        get {
            if let config = storage[HtmxStorageKey.self] {
                return config
            } else {
                let config = HtmxConfiguration()
                storage[HtmxStorageKey.self] = config
                return config
            }
        }
        set {
            if storage[HtmxStorageKey.self] == nil {
                storage[HtmxStorageKey.self] = newValue
            } else {
                fatalError("Redeclaration of HTMX configuraion")
            }
        }
    }
}
