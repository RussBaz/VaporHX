import Vapor

public struct HXLocalisations {
    public var providers: [Locale.LanguageCode: any HXLocalisable]
    public var defaultLanguageCode: Locale.LanguageCode
    public var overrideLanguagePreference: ((_ req: Request) -> Locale.LanguageCode?)?

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

    public init(providers: [Locale.LanguageCode: any HXLocalisable], defaultLanguageCode: Locale.LanguageCode? = nil, overrideLanguagePreference: ((_: Request) -> Locale.LanguageCode)? = nil) {
        self.providers = providers
        self.overrideLanguagePreference = overrideLanguagePreference
        self.defaultLanguageCode = defaultLanguageCode ?? Locale.current.language.languageCode ?? Locale.LanguageCode("en")
    }
}

public extension HXLocalisations {
    init() {
        providers = [:]
        overrideLanguagePreference = nil
        defaultLanguageCode = Locale.current.language.languageCode ?? Locale.LanguageCode("en")
    }
}
