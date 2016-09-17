import COpenSSL

internal extension Hash.Function {
	var digestLength: Int {
		switch self {
		case .md5:
			return Int(MD5_DIGEST_LENGTH)
		case .sha1:
			return Int(SHA_DIGEST_LENGTH)
		case .sha224:
			return Int(SHA224_DIGEST_LENGTH)
		case .sha256:
			return Int(SHA256_DIGEST_LENGTH)
		case .sha384:
			return Int(SHA384_DIGEST_LENGTH)
		case .sha512:
			return Int(SHA512_DIGEST_LENGTH)
		}
	}

	var function: ((UnsafePointer<UInt8>?, Int, UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>!) {
		switch self {
		case .md5:
			return { MD5($0!, $1, $2!) }
		case .sha1:
			return { SHA1($0!, $1, $2!) }
		case .sha224:
			return { SHA224($0!, $1, $2!) }
		case .sha256:
			return { SHA256($0!, $1, $2!) }
		case .sha384:
			return { SHA384($0!, $1, $2!) }
		case .sha512:
			return { SHA512($0!, $1, $2!) }
		}
	}

	var evp: UnsafePointer<EVP_MD> {
		switch self {
		case .md5:
			return EVP_md5()
		case .sha1:
			return EVP_sha1()
		case .sha224:
			return EVP_sha224()
		case .sha256:
			return EVP_sha256()
		case .sha384:
			return EVP_sha384()
		case .sha512:
			return EVP_sha512()
		}
	}
}

public enum HashError: Error {
    case error(description: String)
}

public struct Hash {
	public enum Function {
		case md5, sha1, sha224, sha256, sha384, sha512
	}

	// MARK: - Hash

	public static func hash(_ function: Function, message: Data) -> Data {
		initialize()

		var hashBuf = Data(count: function.digestLength)
		_ = message.withUnsafeBytes { ptr in
			hashBuf.withUnsafeMutableBytes { bufPtr in
				function.function(ptr, message.count, bufPtr)
			}
		}
		return hashBuf
	}

	// MARK: - HMAC

	public static func hmac(_ function: Function, key: Data, message: Data) -> Data {
		initialize()

		var resultLen: UInt32 = 0
		let result = UnsafeMutablePointer<Byte>.allocate(capacity: Int(EVP_MAX_MD_SIZE))
		_ = key.withUnsafeBytes { keyPtr in
			message.withUnsafeBytes { msgPtr in
				COpenSSL.HMAC(function.evp, keyPtr, Int32(key.count), msgPtr, message.count, result, &resultLen)
			}
		}
		let data = Data(Array(UnsafeBufferPointer<Byte>(start: result, count: Int(resultLen))))
		result.deinitialize(count: Int(resultLen))
        result.deallocate(capacity: Int(EVP_MAX_MD_SIZE))
		return data
	}

	// MARK: - RSA

	public static func rsa(_ function: Function, key: Key, message: Data) throws -> Data {
		initialize()

		let ctx = EVP_MD_CTX_create()
		guard ctx != nil else {
			throw HashError.error(description: lastSSLErrorDescription)
		}

        return message.withUnsafeBytes { (digestPtr: UnsafePointer<UInt8>) -> Data in
			EVP_DigestInit_ex(ctx, function.evp, nil)
			EVP_DigestUpdate(ctx, UnsafeRawPointer(digestPtr), message.count)
			var signLen: UInt32 = 0
			var buf = Data(count: Int(EVP_PKEY_size(key.key)))
			_ = buf.withUnsafeMutableBytes { ptr in
				EVP_SignFinal(ctx, ptr, &signLen, key.key)
			}
			return Data(buf.prefix(Int(signLen)))
		}
	}

}
