import Fluent
import Vapor

struct LogController: RouteCollection {
     func boot(routes: RoutesBuilder) throws {
        let logs = routes.grouped("logs")

        // Use JWT middlewarelet tokenProtected = users.grouped(UserAuthMiddleware())

        let tokenProtected = logs.grouped(UserAuthMiddleware())
        tokenProtected.get(use: index)
        tokenProtected.post(use: create)
        tokenProtected.group(":logID") { log in
            log.get(use: show)
            log.put(use: update)
            log.delete(use: delete)
        }
    }
    func index(req: Request) throws -> EventLoopFuture<[Log]> {
        return Log.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Log> {
        let log = try req.content.decode(Log.self)
        return log.save(on: req.db).map { log }
    }

    func show(req: Request) throws -> EventLoopFuture<Log> {
        guard let logIDString = req.parameters.get("logID"),
              let logID = UUID(uuidString: logIDString)
        else {
            throw Abort(.badRequest)
        }
        return Log.find(logID, on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func update(req: Request) throws -> EventLoopFuture<Log> {
        guard let logIDString = req.parameters.get("logID"),
              let logID = UUID(uuidString: logIDString)
        else {
            throw Abort(.badRequest)
        }
        let updateLog = try req.content.decode(Log.self)
        return Log.find(logID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { log in
                log.event = updateLog.event
                log.timestamp = updateLog.timestamp
                log.data = updateLog.data
                log.status = updateLog.status
                log.userUUID = updateLog.userUUID
                return log.save(on: req.db).map { log }
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let logIDString = req.parameters.get("logID"),
              let logID = UUID(uuidString: logIDString)
        else {
            throw Abort(.badRequest)
        }
        return Log.find(logID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { log in
                return log.delete(on: req.db).transform(to: .noContent)
            }
    }
}
