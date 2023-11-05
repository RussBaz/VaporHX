import Vapor

public func configureHtmx(_ app: Application, template: ((_ name: String) -> String)? = nil) throws {
    if let template {
        app.htmx = HtmxConfiguration(template: template)
    } else {
        app.htmx = HtmxConfiguration()
    }

    // Saving currnet sources in case these are the default sources
    app.leaf.sources = app.leaf.sources

    try app.leaf.sources.register(source: "hx", using: app.htmx.pageSource, searchable: true)
}

public func configureLocalisation(_ app: Application, localisations: HXLocalisations) throws {
    app.leaf.tags["t"] = HXTextTag()
    app.localisations = localisations
}
