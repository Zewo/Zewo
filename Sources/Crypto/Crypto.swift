import Core
import COpenSSL

public struct Crypto {
    public static func hmacSHA256(
        _ string: String,
        key: UnsafeRawBufferPointer,
        buffer: UnsafeMutableRawBufferPointer
    ) -> UnsafeRawBufferPointer {
        guard buffer.count >= Int(EVP_MAX_MD_SIZE) else {
            // invalid buffer size
            return UnsafeRawBufferPointer(start: nil, count: 0)
        }
        
        var bufferCount: UInt32 = 0
        
        let result = string.withCString {
            HMAC(
                EVP_sha256(),
                key.baseAddress,
                Int32(key.count),
                UnsafeRawPointer($0).assumingMemoryBound(to: UInt8.self),
                string.utf8.count,
                buffer.baseAddress?.assumingMemoryBound(to: UInt8.self),
                &bufferCount
            )
        }
        
        guard result != nil else {
            return UnsafeRawBufferPointer(start: nil, count: 0)
        }
        
        return UnsafeRawBufferPointer(buffer.prefix(upTo: Int(bufferCount)))
    }

    public static func hmacSHA256(
        _ string: String,
        key: BufferRepresentable,
        buffer: UnsafeMutableRawBufferPointer
    ) -> UnsafeRawBufferPointer {
        return key.withBuffer {
            hmacSHA256(string, key: $0, buffer: buffer)
        }
    }

    public static func hmacSHA256<B : BufferInitializable>(
        _ string: String,
        key: BufferRepresentable
    ) -> B {
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: Int(EVP_MAX_MD_SIZE))
        
        defer {
            buffer.deallocate()
        }
        
        return B(hmacSHA256(string, key: key, buffer: buffer))
    }

    public static func sha256(
        _ string: String,
        buffer: UnsafeMutableRawBufferPointer
    ) -> UnsafeRawBufferPointer {
        guard buffer.count >= Int(SHA256_DIGEST_LENGTH) else {
            // invalid buffer size
            return UnsafeRawBufferPointer(start: nil, count: 0)
        }
        
        var sha256 = SHA256_CTX()
        SHA256_Init(&sha256)
        
        _ = string.withCString {
            SHA256_Update(&sha256, $0, string.utf8.count)
        }
        
        SHA256_Final(buffer.baseAddress?.assumingMemoryBound(to: UInt8.self), &sha256)
        
        return UnsafeRawBufferPointer(buffer.prefix(Int(SHA256_DIGEST_LENGTH)))
    }

    public static func sha256<B : BufferInitializable>(_ string: String) -> B  {
        let buffer = UnsafeMutableRawBufferPointer.allocate(count: Int(SHA256_DIGEST_LENGTH))
        
        defer {
            buffer.deallocate()
        }
        
        return B(sha256(string, buffer: buffer))
    }
}
