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

    // Saving currnet sources in case these are the default sources
    app.leaf.sources = app.leaf.sources

    try app.leaf.sources.register(source: "hx", using: app.htmx.pageSource, searchable: true)
}

public func configureLocalisation(_ app: Application, localisations: HXLocalisations) throws {
    app.leaf.tags["t"] = HXTextTag()
    app.localisations = localisations
}