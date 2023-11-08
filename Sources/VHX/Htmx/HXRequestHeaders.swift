import Vapor

public struct HXRequestHeaders {
    let boosted: Bool
    let currentUrl: String?
    let historyRestoreRequest: Bool
    let prompt: Bool
    let request: Bool
    let target: String?
    let triggerName: String?
    let trigger: String?
}

extension HXRequestHeaders {
    init(headers: HTTPHeaders) {
        boosted = if let restore = headers["HX-Boosted"].first { restore == "true" } else { false }
        currentUrl = headers["HX-Current-URL"].first
        historyRestoreRequest = if let restore = headers["HX-History-Restore-Request"].first { restore == "true" } else { false }
        prompt = if let restore = headers["HX-Prompt"].first { restore == "true" } else { false }
        request = if let restore = headers["HX-Request"].first { restore == "true" } else { false }
        target = headers["HX-Target"].first
        triggerName = headers["HX-Trigger-Name"].first
        trigger = headers["HX-Trigger"].first
    }
}
