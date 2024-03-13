import Vapor

struct DeleteRowController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let deleteRow = routes.grouped("deleteRow")

        deleteRow.get { req async throws in
            try await req.htmx.render("DeleteRow/delete-row", ["users": req.application.deleteRow.users])
        }

        deleteRow.delete(":id") { req async throws in
            // Ensure we have a valid user ID
            guard let idString = req.parameters.get("id"), let id = UUID(uuidString: idString) else { return HTTPStatus.notFound }
            var users = req.application.deleteRow.users

            if let match = users.firstIndex(where: { $0.id == id }) {
                users.remove(at: match)
                req.application.deleteRow = DeleteRow(users: users)
                return HTTPStatus.ok
            }

            return HTTPStatus.notFound
        }
    }
}

/// - Warning: Don't do this in production!
struct DeleteRow: Content {
    struct Key: StorageKey {
        typealias Value = DeleteRow
    }

    struct User: Content {
        let id: UUID
        let name: String
        let email: String
        let status: String

        init(name: String, email: String, status: String) {
            id = UUID()
            self.name = name
            self.email = email
            self.status = status
        }
    }

    var users: [User]

    static var `default`: DeleteRow = .init(users: [
        .init(name: "Joe Smith", email: "joe@smith.org", status: "Active"),
        .init(name: "Angie MacDowell", email: "angie@macdowell.org", status: "Active"),
        .init(name: "Fuqua Tarkenton", email: "fuqua@terkenton.org", status: "Active"),
        .init(name: "Kim Yee", email: "kim@yee.org", status: "Inactive"),
    ])
}

extension Application {
    var deleteRow: DeleteRow {
        get {
            storage[DeleteRow.Key.self] ?? DeleteRow.default
        }
        set {
            storage[DeleteRow.Key.self] = newValue
        }
    }
}
