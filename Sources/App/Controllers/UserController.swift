import Vapor
import JWT
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post("login", use: login)
        users.post("logout", use: logout)
        users.post("register", use: register)
        
        // Use JWT middleware
        let tokenProtected = users.grouped(UserAuthMiddleware())
        tokenProtected.get(use: index)
        tokenProtected.post(use: create)
        tokenProtected.group(":userID") { user in
            user.get(use: show)
            user.put(use: update)
            user.delete(use: delete)
        }
    }

    func show(req: Request) throws -> EventLoopFuture<User> {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        return User.find(user.id, on: req.db).unwrap(or: Abort(.notFound))
    }

    func index(req: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        let hashedPassword = try req.application.password.hash(user.password)
        user.password = hashedPassword
        return user.save(on: req.db).map { user }
    }

    func update(req: Request) throws -> EventLoopFuture<User> {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        let updateUser = try req.content.decode(User.self)
        return User.find(user.id, on: req.db)
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
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        return User.find(user.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }

    func register(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        let hashedPassword = try req.application.password.hash(user.password)
        user.password = hashedPassword
        return user.save(on: req.db).map { user }
    }

    func login(req: Request) throws -> EventLoopFuture<String> {
        let user = try req.content.decode(User.self)
        return User.query(on: req.db)
        .filter(\.$username == user.username)
        .first()
        .unwrap(or: Abort(.notFound))
        .flatMap { existingUser in
            do {
                let passwordHash = try req.application.password.verify(user.password, created: existingUser.password)
                guard passwordHash == true else {
                    return req.eventLoop.makeFailedFuture(Abort(.unauthorized))
                }
                let userID = try existingUser.requireID().uuidString
                let jwt = try req.jwt.sign(UserPayload(name: existingUser.username, userID: userID))
                return req.eventLoop.makeSucceededFuture(jwt)
            } catch {
                return req.eventLoop.makeFailedFuture(error)
            }
        }
    }
    func logout(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        req.auth.logout(User.self)
        return req.eventLoop.makeSucceededFuture(.ok)
    }
}
