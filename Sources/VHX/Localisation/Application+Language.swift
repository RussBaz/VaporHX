import Vapor

public extension Application {
    struct LocalisationStorageKey: StorageKey {
        public typealias Value = HXLocalisations
    }

    var localisations: HXLocalisations {
        get {
            storage[LocalisationStorageKey.self] ?? HXLocalisations()
        }
        set {
            if storage[LocalisationStorageKey.self] == nil {
                storage[LocalisationStorageKey.self] = newValue
            } else {
                fatalError("Redeclaration of Localisations")
            }
        }
    }
}
