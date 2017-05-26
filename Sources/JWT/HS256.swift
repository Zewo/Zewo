import Crypto

extension JWT.Algorithm {
    public static func hs256(key: String) -> JWT.Algorithm {
        return JWT.Algorithm(
            name: "HS256",
            sign: { message in
                Crypto.hs256(message, key: key)
            },
            verify: { signature, message in
                guard signature == Crypto.hs256(message, key: key) else {
                    throw JWTError.invalidSignature
                }
            }
        )
    }
}
