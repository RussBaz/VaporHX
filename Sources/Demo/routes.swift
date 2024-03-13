import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.htmx.render("home", ["examples": Examples])
    }

    /// Examples
    try app.register(collection: ClickToEditController())

    try app.register(collection: BulkUpdateController())

    try app.register(collection: ClickToLoadController())

    try app.register(collection: DeleteRowController())

    try app.register(collection: LazyLoadingController())

    try app.register(collection: InfiniteScrollController())

    try app.register(collection: ActiveSearchController())

    try app.register(collection: CascadingSelectController())
}

struct Example: Content {
    let url: String
    let title: String
}

let Examples: [Example] = [
    .init(url: "contact/1", title: "Click To Edit"),
    .init(url: "users", title: "Bulk Update"),
    .init(url: "contacts", title: "Click To Load"),
    .init(url: "deleteRow", title: "Delete Row"),
    .init(url: "lazy", title: "Lazy Loading"),
    .init(url: "infinite", title: "Infinite Scroll"),
    .init(url: "activeSearch", title: "Active Search"),
    .init(url: "select/models", title: "Cascading Select"),
]
