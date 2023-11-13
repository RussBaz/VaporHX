import Vapor

public struct HXLocalisations {
    public let providers: [Locale.LanguageCode: any HXLocalisable]
    public let overrideLanguagePreference: ((_ req: Request) -> Locale.LanguageCode)?

    public func localise(text: String, for code: Locale.LanguageCode) -> String {
        guard code.isISOLanguage else { return text }
        if let localisation = providers[code] {
            return localisation.localise(text: text)
        } else if let language = code.identifier(.alpha2),
                  let localisation = providers[Locale.LanguageCode(stringLiteral: language)]
        {
            return localisation.localise(text: text)
        }

        return text
    }

    public init(providers: [Locale.LanguageCode: any HXLocalisable], overrideLanguagePreference: ((_: Request) -> Locale.LanguageCode)? = nil) {
        self.providers = providers
        self.overrideLanguagePreference = overrideLanguagePreference
    }
}

public extension HXLocalisations {
    init() {
        providers = [:]
        overrideLanguagePreference = nil
    }
}
