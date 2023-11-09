import Vapor

public struct HXRequestHeaders {
    public let boosted: Bool
    public let currentUrl: String?
    public let historyRestoreRequest: Bool
    public let prompt: Bool
    public let request: Bool
    public let target: String?
    public let triggerName: String?
    public let trigger: String?
}

public extension HXRequestHeaders {
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
