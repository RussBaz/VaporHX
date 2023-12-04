import Vapor

public func configureHtmx(_ app: Application, pageTemplate template: ((_ name: String) -> String)? = nil) throws {
    let config = if let template {
        HtmxConfiguration(pageTemplate: template)
    } else {
        HtmxConfiguration()
    }

    try configureHtmx(app, configuration: config)
}

public func configureHtmx(_ app: Application, configuration: HtmxConfiguration) throws {
    app.htmx = configuration
    app.middleware.use(HXErrorMiddleware())

    app.views.use(.leaf)
    // Saving currnet sources in case these are the default sources
    app.leaf.sources = app.leaf.sources

    try app.leaf.sources.register(source: "hx", using: app.htmx.pageSource, searchable: true)
}

public func configureLocalisation(_ app: Application, localisations: HXLocalisations, textTag: String = "t") throws {
    app.leaf.tags[textTag] = HXTextTag()
    app.localisations = localisations
}

public func staticRoute(template: String) -> ((Request) async throws -> Response) {
    { (req: Request) async throws in
        try await req.htmx.render(template)
    }
}
