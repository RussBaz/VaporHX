import Vapor

struct ClickToEditController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let clickToEdit = routes.grouped("contact")

        struct Contact1Feedback: Content {
            let contact: Contact1?
            let feedback: String?
        }

        clickToEdit.get("1") { req async throws in
            if req.application.contact1 == nil {
                req.application.contact1 = Contact1(firstName: "Joe", lastName: "Blow", email: "joe@blow.com")
            }

            return try await req.htmx.render("ClickToEdit/click-to-edit", ["contact": req.application.contact1])
        }

        clickToEdit.put("1") { req async throws in
            let put = try req.content.decode(Contact1.self)
            do {
                try Contact1.validate(content: req)
                req.logger.info("\(put)")
                req.application.contact1 = put
            } catch {
                if let ve = error as? ValidationsError {
                    return try await req.htmx.render("ClickToEdit/click-to-edit-form", ["in": Contact1Feedback(contact: put, feedback: ve.description)])
                }
            }
            return req.redirect(to: "/contact/1")
        }

        clickToEdit.get("1", "edit") { req async throws in
            try await req.htmx.render("ClickToEdit/click-to-edit-form", ["in": Contact1Feedback(contact: req.application.contact1, feedback: nil)])
        }
    }
}

/// - Warning: Don't do this in production!
struct Contact1: Content, Validatable {
    struct Key: StorageKey {
        typealias Value = Contact1
    }

    var firstName: String
    var lastName: String
    var email: String

    static func validations(_ validations: inout Validations) {
        validations.add("firstName", as: String.self, is: .count(2 ... 20))
        validations.add("firstName", as: String.self, is: .characterSet(.letters))

        validations.add("lastName", as: String.self, is: .count(2 ... 20))
        validations.add("lastName", as: String.self, is: .characterSet(.letters))

        validations.add("email", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
    }
}

extension Application {
    var contact1: Contact1? {
        get {
            storage[Contact1.Key.self]
        }
        set {
            storage[Contact1.Key.self] = newValue
        }
    }
}
