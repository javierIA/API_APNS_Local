import Vapor
import Fluent

final class Log: Model, Content {
    static let schema = "logs"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "event")
    var event: String
    
    @Field(key: "timestamp")
    var timestamp: Date?
    
    @Field(key: "data")
    var data: [String: String]?
    
    @Field(key: "status")
    var status: String?
    
    @Field(key: "user_uuid")
    var userUUID: UUID?
    
    @Parent(key: "user_uuid")
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, event: String, timestamp: Date? = nil, data: [String: String]? = nil, status: String? = nil, userUUID: UUID? = nil) {
        self.id = id
        self.event = event
        self.timestamp = timestamp
        self.data = data
        self.status = status
        self.userUUID = userUUID
    }
}
