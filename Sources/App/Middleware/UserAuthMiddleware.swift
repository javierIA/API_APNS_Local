import Vapor
import Fluent
import JWT

struct UserAuthMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if let jwt = try? request.jwt.verify(as: UserPayload.self) {
            guard let uuid = UUID(uuidString: jwt.userID) else {
                return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
            }
            return User.find(uuid, on: request.db).flatMap { userOptional in
                if let user = userOptional {
                    request.auth.login(user)
                }
                return next.respond(to: request)
            }
        } else {
            return next.respond(to: request)
        }
    }
}
