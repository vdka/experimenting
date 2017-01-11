
import UIKit
import JSON

extension Unsplash {

    struct Image {
        let id: String
        let photographer: User
        let likes: Int
        let uploadedAt: Date
        let height: Int
        let width: Int
        let fullUrl: URL
        let smallUrl: URL
        let customUrl: URL
        let color: String
    }

    struct User {
        let id: String
        let name: String
        let username: String
    }
}

extension Unsplash.Image: JSONInitializable {

    init(json: JSON) throws {
        self.id             = try json.get("id")
        self.photographer   = try json.get("user")
        self.likes          = try json.get("likes")
        self.uploadedAt     = try json.get("created_at")
        self.height         = try json.get("height")
        self.width          = try json.get("width")
        self.fullUrl        = try (json.get("urls") as JSON).get("full")
        self.smallUrl       = try (json.get("urls") as JSON).get("small")
        self.customUrl      = try (json.get("urls") as JSON).get("custom")
        self.color          = try json.get("color")
    }
}

extension Unsplash.User: JSONInitializable {

    init(json: JSON) throws {
        self.id = try json.get("id")
        self.name = try json.get("name")
        self.username = try json.get("username")
    }
}
