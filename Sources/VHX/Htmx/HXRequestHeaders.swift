import Vapor

public struct HXRequestHeaders {
    let headers: HTTPHeaders

    var boosted: Bool { bool(for: "HX-Boosted") }
    var currentUrl: String? { headers["HX-Current-URL"].first }
    var historyRestoreRequest: Bool { bool(for: "HX-History-Restore-Request") }
    var prompt: Bool { bool(for: "HX-Prompt") }
    var request: Bool { bool(for: "HX-Request") }
    var target: String? { headers["HX-Target"].first }
    var triggerName: String? { headers["HX-Trigger-Name"].first }
    var trigger: String? { headers["HX-Trigger"].first }
}

public extension HXRequestHeaders {
    private func bool(for name: String) -> Bool {
        guard !name.isEmpty else { return false }
        return if let restore = headers[name].first { restore == "true" } else { false }
    }
}
