import Vapor

public struct HXRequestLocalisation {
    let req: Request

    public func localise(text: String, for code: Locale.LanguageCode? = nil) -> String {
        let code = code ?? prefered

        return req.application.localisations.localise(text: text, for: code)
    }

    public var prefered: Locale.LanguageCode {
        let override: Locale.LanguageCode? = if let overrideLanguagePreference = req.application.localisations.overrideLanguagePreference {
            overrideLanguagePreference(req)
        } else {
            nil
        }

        return override ?? req.headers.language.prefered
    }
}
