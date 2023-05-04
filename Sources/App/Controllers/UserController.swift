import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post(use: create)
        users.group(":userID") { user in
            user.delete(use: delete)
            user.put(use: update)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }

    func update(req: Request) throws -> EventLoopFuture<User> {
        let userID = try req.parameters.require("userID", as: UUID.self)
        let updateUser = try req.content.decode(User.self)
        return User.find(userID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.username = updateUser.username
                user.role = updateUser.role
                user.password = updateUser.password
                user.email = updateUser.email
                user.verified = updateUser.verified
                return user.save(on: req.db).map { user }
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let userID = try req.parameters.require("userID", as: UUID.self)
        return User.find(userID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
