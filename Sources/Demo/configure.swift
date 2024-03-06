import VHX
import LeafKit
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    
    let pathToPublic = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("Public").relativePath
    app.middleware.use(FileMiddleware(publicDirectory: pathToPublic))

    let pathToViews = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("Views").relativePath
    app.leaf.sources = LeafSources.singleSource(
        NIOLeafFiles(fileio: app.fileio,
                     limits: .default,
                     sandboxDirectory: pathToViews,
                     viewDirectory: pathToViews))
    
    app.views.use(.leaf)

    let hxConfig = HtmxConfiguration.basic()
    try configureHtmx(app, configuration: hxConfig)

    // register routes
    try routes(app)
}
