import COpenSSL

private extension UInt8 {
	var hexString: String {
		let string = String(self, radix: 16)
		return (self < 16 ? "0" + string : string)
	}
}

private extension X509 {
	var validityNotBefore: UnsafeMutablePointer<ASN1_TIME> {
		return cert_info.pointee.validity.pointee.notBefore
	}

	var validityNotAfter: UnsafeMutablePointer<ASN1_TIME> {
		return cert_info.pointee.validity.pointee.notAfter
	}
}

public enum CertificateError : Error {
    case certificate
    case subject
    case privateKey
    case `extension`
    case sign
}

public class Certificate {
	var certificate: UnsafeMutablePointer<X509>?

	public func getFingerprint(function: Hash.Function = .sha256) -> String {
		let md = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(EVP_MAX_MD_SIZE))
        defer { md.deinitialize(); md.deallocate(capacity: Int(EVP_MAX_MD_SIZE)) }
		var n: UInt32 = 0
		X509_digest(certificate, function.evp, md, &n)
		return UnsafeMutableBufferPointer(start: md, count: Int(EVP_MAX_MD_SIZE)).makeIterator().prefix(Int(n)).map({ $0.hexString }).joined(separator: ":")
	}

	init(certificate: UnsafeMutablePointer<X509>) {
		initialize()
		self.certificate = certificate
	}

	public init(privateKey: Key, commonName: String, expiresInDays: Int = 365, subjectAltName: String? = nil, function: Hash.Function = .sha256) throws {
		initialize()

		let privateKey = privateKey.key
		var ret: Int32 = 0

		certificate = X509_new()

		guard let certificate = certificate else {
			throw CertificateError.certificate
		}

		let subject = X509_NAME_new()
		var ext = X509_EXTENSION_new()

        let serial = Random.number()
		ASN1_INTEGER_set(X509_get_serialNumber(certificate), Int(serial))

		ret = X509_NAME_add_entry_by_txt(subject, "CN", (MBSTRING_FLAG|1), commonName, Int32(commonName.utf8.count), -1, 0)
		guard ret >= 0 else { throw CertificateError.subject }

		ret = X509_set_issuer_name(certificate, subject)
		guard ret >= 0 else { throw CertificateError.subject }
		ret = X509_set_subject_name(certificate, subject)
		guard ret >= 0 else { throw CertificateError.subject }

		X509_gmtime_adj(certificate.pointee.validityNotBefore, 0)
		X509_gmtime_adj(certificate.pointee.validityNotAfter, expiresInDays*86400)

		ret = X509_set_pubkey(certificate, privateKey)
		guard ret >= 0 else { throw CertificateError.privateKey }

		if let subjectAltName = subjectAltName {
			try subjectAltName.withCString { strPtr in
				ext = X509V3_EXT_conf_nid(nil, nil, NID_subject_alt_name, UnsafeMutablePointer<CChar>(mutating: strPtr))
				ret = X509_add_ext(certificate, ext, -1)
				X509_EXTENSION_free(ext)
				guard ret >= 0 else { throw CertificateError.extension }
			}
		}

		try "CA:FALSE".withCString { strPtr in
			ext = X509V3_EXT_conf_nid(nil, nil, NID_basic_constraints, UnsafeMutablePointer<CChar>(mutating: strPtr))
			ret = X509_add_ext(certificate, ext, -1)
			X509_EXTENSION_free(ext)
			guard ret >= 0 else { throw CertificateError.extension }
		}

		// TODO: add extensions NID_subject_key_identifier and NID_authority_key_identifier

		ret = X509_sign(certificate, privateKey, function.evp)
		guard ret >= 0 else { throw CertificateError.sign }
	}

	deinit {
		X509_free(certificate)
	}
}
