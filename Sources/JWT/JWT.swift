import Content
import Foundation

public enum JWTError : Error {
    case invalidHeader
    case invalidPayload
    case invalidToken
    case algorithmDoesNotMatch
    case invalidSignature
}

public struct JWT {
    public struct Algorithm {
        public let name: String
        let sign: (String) throws -> Data
        let verify: (Data, String) throws -> Void
        
        public init(
            name: String,
            sign: @escaping (_ message: String) throws -> Data,
            verify: @escaping (_ signature: Data, _ message: String) throws -> Void
        ) {
            self.name = name
            self.sign = sign
            self.verify = verify
        }
    }
    
    private let jsonHeader: JSON
    private let jsonPayload: JSON
    private let signature: Data
    private let message: String
    
    public init(
        header: JSON = [:],
        payload: JSON,
        algorithm: Algorithm
    ) throws {
        var defaultHeader: [String: JSON] = [
            "typ": "JWT",
            "alg": .string(algorithm.name)
        ]
        
        guard case let .object(object) = header, case .object = payload else {
            throw JWTError.invalidHeader
        }
        
        for (key, value) in object {
            defaultHeader[key] = value
        }
        
        self.jsonHeader = JSON.object(defaultHeader)
        self.jsonPayload = payload
        
        guard let encodedHeader = self.jsonHeader.description.base64URLEncoded() else {
            throw JWTError.invalidHeader
        }
        
        guard let encodedPayload = self.jsonPayload.description.base64URLEncoded() else {
            throw JWTError.invalidPayload
        }
        
        self.message = encodedHeader + "." + encodedPayload
        self.signature = try algorithm.sign(self.message)
    }
    
    public init(token: String) throws {
        let components = token.components(separatedBy: ".")
        
        guard components.count == 3 else {
            throw JWTError.invalidToken
        }
        
        guard let decodedHeader = components[0].base64URLDecoded() else {
            throw JWTError.invalidToken
        }
        
        self.jsonHeader = try decodedHeader.withBuffer {
            try JSON.parse($0, deadline: .never)
        }

        guard let decodedPayload = components[1].base64URLDecoded() else {
            throw JWTError.invalidToken
        }
        
        self.jsonPayload = try decodedPayload.withBuffer {
            try JSON.parse($0, deadline: .never)
        }
        
        guard let decodedSignature = components[2].base64URLDecoded() else {
            throw JWTError.invalidToken
        }
        
        self.message = components[0] + "." + components[1]
        self.signature = decodedSignature
    }
    
    public func token() throws -> String {
        guard let signature = self.signature.base64URLEncoded() else {
            throw JWTError.invalidSignature
        }
        
        return message + "." + signature
    }
    
    public static func token(
        header: JSON = [:],
        payload: JSON,
        using algorithm: Algorithm
    ) throws -> String {
        let jwt = try JWT(
            header: header,
            payload: payload,
            algorithm: algorithm
        )
    
        return try jwt.token()
    }
    
    public func verify(using algorithm: Algorithm) throws {
        guard try algorithm.name == jsonHeader.get("alg") else {
            throw JWTError.algorithmDoesNotMatch
        }
        
        try algorithm.verify(signature, message)
    }
    
    public static func verify(_ token: String, using algorithm: Algorithm) throws {
        let jwt = try JWT(token: token)
        try jwt.verify(using: algorithm)
    }
    
    public func header() -> JSON {
        return jsonHeader
    }
    
    public func header<I : JSONInitializable>() throws -> I {
        return try I(json: jsonHeader)
    }
    
    public func payload() -> JSON {
        return jsonPayload
    }
    
    public func payload<I : JSONInitializable>() throws -> I {
        return try I(json: jsonPayload)
    }
}

extension Data {
    func base64URLEncoded() -> String? {
        return base64EncodedString()
            .replacingOccurrences(
                of: "+",
                with: "-"
            ).replacingOccurrences(
                of: "/",
                with: "_"
            ).replacingOccurrences(
                of: "=",
                with: ""
            )
    }
}

extension String {
    func base64URLEncoded() -> String? {
        return data(using: .utf8)?.base64URLEncoded()
    }
    
    func base64URLDecoded() -> Data? {
        let remainder = utf8.count % 4
        let padding =  remainder > 0 ? String(repeating: "=", count: 4 - remainder) : ""
        
        let base64 = replacingOccurrences(
                of: "-",
                with: "+",
                options: [],
                range: nil
            ).replacingOccurrences(
                of: "_",
                with: "/",
                options: [],
                range: nil
            ) + padding
        
        return Data(base64Encoded: base64)
    }
}
