import Fluent
import Vapor
import JWTKit
import FluentPostgresDriver

public func configure(_ app: Application) throws {
    // Configurar el proveedor de Fluent y la base de datos
    app.databases.use(.postgres(
        hostname:"localhost",
        port: 5432,
        username:  "vapor_username",
        password:  "vapor_password",
        database: "vapor_database"
    ), as: .psql)

    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateLogs())
    
    // Configurar el autenticador JWT
    let privateKey = try String(contentsOfFile: "Keys/private_key.pem")
    let jwtSigner = try JWTSigner.rs256(key: .private(pem: [UInt8](privateKey.data(using: .utf8)!)))
    app.jwt.signers.use(jwtSigner)
    
    // Configurar el middleware para el autenticador JWT
    app.middleware.use(UserAuthMiddleware())
    // Ejecutar las migraciones
    try app.autoMigrate().wait()
    // Configurar las rutas
    try routes(app)
}
