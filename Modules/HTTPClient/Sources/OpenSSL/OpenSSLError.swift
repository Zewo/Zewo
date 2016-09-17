import COpenSSL

var lastSSLErrorDescription: String {
	let error = ERR_get_error()
	if let string = ERR_reason_error_string(error) {
		return String(validatingUTF8: string) ?? "Unknown Error"
	} else {
		return "Unknown Error"
	}
}
