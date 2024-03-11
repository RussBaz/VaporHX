import Vapor

struct BulkUpdateController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let bulkUpdate  = routes.grouped("users")
        
        struct BulkUpdateFeedback:Content {
            let contact:Contact1?
            let feedback:String?
        }
        
        bulkUpdate.get { req async throws in
            return try await req.htmx.render("BulkUpdate/bulk-update", ["users": req.application.bulkUpdate.users])
        }
        
        bulkUpdate.post { req async throws in
            let update = try req.content.decode([String:String].self)
            req.logger.info("\(update)")
            
            // Apply and log updates
            var updates:[String] = []
            var users = req.application.bulkUpdate.users
            for i in 0..<users.count {
                if let entry = update[users[i].email], entry == "on" {
                    if !users[i].isActive {
                        users[i].setActive(true)
                        updates.append("Changed \(users[i].email) to active")
                    }
                } else {
                    if users[i].isActive {
                        users[i].setActive(false)
                        updates.append("Changed \(users[i].email) to inactive")
                    }
                }
            }
            
            // Update our storage
            req.application.bulkUpdate = BulkUpdate(users: users)
            
            // If there weren't changes, let the user know
            if updates.isEmpty {
                updates.append("No Changes")
            }
            
            // Return the toast / feedback
            return """
            <span id="toast">\(updates.joined(separator: ", "))</span>
            """
        }
    }
}

/// - Warning: Don't do this in production!
struct BulkUpdate:Content, Validatable {
    struct Key: StorageKey {
        typealias Value = BulkUpdate
    }
    struct User:Content {
        let name:String
        let email:String
        var isActive:Bool
        
        mutating func setActive(_ active:Bool) {
            self.isActive = active
        }
    }
    
    var users:[User]
    
    static func validations(_ validations: inout Validations) {
        validations.add("users", as: Array<User>.self, is: .count(4...4))
    }
    
    static var `default`:BulkUpdate = .init(users: [
        .init(name: "Joe Smith", email: "joe@smith.org", isActive: true),
        .init(name: "Angie MacDowell", email: "angie@macdowell.org", isActive: true),
        .init(name: "Fuqua Tarkenton", email: "fuqua@terkenton.org", isActive: true),
        .init(name: "Kim Yee", email: "kim@yee.org", isActive: false),
    ])
}

extension Application {
    var bulkUpdate: BulkUpdate {
        get {
            self.storage[BulkUpdate.Key.self] ?? BulkUpdate.default
        }
        set {
            self.storage[BulkUpdate.Key.self] = newValue
        }
    }
}
