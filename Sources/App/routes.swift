import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    app.passwords.use(.bcrypt(cost: 8))
    
    try app.register(collection: UserController())
    try app.register(collection: LogController())
}
