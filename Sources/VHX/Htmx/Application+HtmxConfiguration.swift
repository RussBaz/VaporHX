import Vapor

public extension Application {
    struct HtmxStorageKey: StorageKey {
        public typealias Value = HtmxConfiguration
    }

    var htmx: HtmxConfiguration {
        get {
            storage[HtmxStorageKey.self] ?? HtmxConfiguration()
        }
        set {
            if storage[HtmxStorageKey.self] == nil {
                storage[HtmxStorageKey.self] = newValue
            } else {
                fatalError("Rediclaration of HTMX configuraion")
            }
        }
    }
}
