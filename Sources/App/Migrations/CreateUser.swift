import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required)
            .field("role", .string, .required)
            .field("created_at", .datetime, .required)
            .field("password", .string, .required)
            .field("description", .string, .required)
            .field("email", .string, .required)
            .field("phone", .string, .required)
            .field("verified", .bool, .required)
            .field("verification_token", .string, .required)
            .field("reset_token", .string, .required)
            .field("reset_token_expiration", .datetime, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
