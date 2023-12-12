import Vapor

public struct HXRequestLocalisation {
    let req: Request

    public func localise(text: String, for code: Locale.LanguageCode? = nil) -> String {
        let code = code ?? prefered

        return req.application.localisations.localise(text: text, for: code)
    }

    public var prefered: Locale.LanguageCode {
        if let overrideLanguagePreference = req.application.localisations.overrideLanguagePreference,
           let code = overrideLanguagePreference(req)
        {
            code
        } else {
            req.headers.language(fallback: req.application.localisations.defaultLanguageCode).prefered
        }
    }
}
