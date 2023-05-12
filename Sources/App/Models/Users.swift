import Fluent
import Vapor

final class User: Model, Content, Authenticatable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "role")
    var role: String

    @Field(key: "created_at")
    var createdAt: Date

    @Field(key: "password")
    var password: String

    @Field(key: "description")
    var description: String

    @Field(key: "email")
    var email: String

    @Field(key: "phone")
    var phone: String

    @Field(key: "verified")
    var verified: Bool

    @Field(key: "verification_token")
    var verificationToken: String

    @Field(key: "reset_token")
    var resetToken: String

    @Field(key: "reset_token_expiration")
    var resetTokenExpiration: Date

    // Agregar la relación con UserToken
  
    init() {
        // Required by Fluent
    }

    init(id: UUID? = nil, username: String, role: String, createdAt: Date = Date(), password: String, description: String, email: String, phone: String, verified: Bool, verificationToken: String, resetToken: String, resetTokenExpiration: Date) {
        self.id = id
        self.username = username
        self.role = role
        self.createdAt = createdAt
        self.password = password
        self.description = description
        self.email = email
        self.phone = phone
        self.verified = verified
        self.verificationToken = verificationToken
        self.resetToken = resetToken
        self.resetTokenExpiration = resetTokenExpiration
    }
}
