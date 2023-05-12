import JWTKit
import Foundation

struct UserPayload: JWTPayload {
    var name: String
    var userID: String

    func verify(using signer: JWTSigner) throws {
        // Implementar cualquier verificación necesaria aquí.
        // Si no necesitas ninguna verificación, puedes dejar esto vacío.
    }
}
