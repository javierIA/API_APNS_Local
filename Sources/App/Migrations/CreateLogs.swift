import Fluent

struct CreateLogs: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("logs")
            .id()
            .field("event", .string, .required)
            .field("timestamp", .datetime)
            .field("data", .json, .required)
            .field("status", .string)
            .field("user_uuid", .uuid, .references("users", "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("logs").delete()
    }
}
