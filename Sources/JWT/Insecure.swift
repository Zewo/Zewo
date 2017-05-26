import Foundation

extension JWT.Algorithm {
    public static var insecure: JWT.Algorithm = JWT.Algorithm(
        name: "none",
        sign: { _ in Data() },
        verify: { signature, message in
            guard signature.isEmpty else {
                throw JWTError.invalidSignature
            }
        }
    )
}
