#if os(OSX) || os(iOS) || os(tvOS) || os(watchOS)
	import Darwin
#elseif os(Linux)
	import Glibc
#endif

import COpenSSL

public enum SSLRandomError: Error {
    case error(description: String)
}

public class Random {
	public static func number(max: Int = Int(UInt32.max)) -> Int {
		#if os(OSX) || os(iOS) || os(tvOS) || os(watchOS)
			return Int(arc4random_uniform(UInt32(max)))
		#elseif os(Linux)
			return Int(random() % (max + 1))
		#endif
	}

	public static func bytes(_ size: Int) throws -> Data {
		var buffer = Data(count: size)
		guard (buffer.withUnsafeMutableBytes { RAND_bytes($0, Int32(buffer.count)) }) == 1 else {
			throw SSLRandomError.error(description: lastSSLErrorDescription)
		}
		return buffer
	}
}
