import COpenSSL

public let BIO_TYPE_DWRAP: Int32 = (50 | 0x0400 | 0x0200)

private var methods_dwrap = BIO_METHOD(type: BIO_TYPE_DWRAP, name: "dtls_wrapper", bwrite: dwrap_write, bread: dwrap_read, bputs: dwrap_puts, bgets: dwrap_gets, ctrl: dwrap_ctrl, create: dwrap_new, destroy: dwrap_free, callback_ctrl: { bio, cmd, fp in
	return BIO_callback_ctrl(bio!.pointee.next_bio, cmd, fp)
})

private func getPointer<T>(_ arg: UnsafeMutablePointer<T>) -> UnsafeMutablePointer<T> {
	return arg
}

public func BIO_f_dwrap() -> UnsafeMutablePointer<BIO_METHOD> {
	return getPointer(&methods_dwrap)
}

func OPENSSL_malloc(_ num: Int, file: String = #file, line: Int = #line) -> UnsafeMutableRawPointer {
	return CRYPTO_malloc(Int32(num), file, Int32(line))
}

func OPENSSL_free(_ ptr: UnsafeMutableRawPointer) {
	CRYPTO_free(ptr)
}

let BIO_FLAGS_RWS = (BIO_FLAGS_READ|BIO_FLAGS_WRITE|BIO_FLAGS_IO_SPECIAL)
func BIO_clear_retry_flags(_ b: UnsafeMutablePointer<BIO>) {
	BIO_clear_flags(b, BIO_FLAGS_RWS|BIO_FLAGS_SHOULD_RETRY)
}

private struct BIO_F_DWRAP_CTX {
	var dgram_timer_exp: Bool
}

private func dwrap_new(bio: UnsafeMutablePointer<BIO>?) -> Int32 {
	let ctx = OPENSSL_malloc(MemoryLayout<BIO_F_DWRAP_CTX>.size)

	memset(ctx, 0, MemoryLayout<BIO_F_DWRAP_CTX>.size)

	let b = bio!.pointee
	bio!.pointee = BIO(method: b.method, callback: b.callback, cb_arg: b.cb_arg, init: 1, shutdown: b.shutdown, flags: 0, retry_reason: b.retry_reason, num: b.num, ptr: ctx, next_bio: b.next_bio, prev_bio: b.prev_bio, references: b.references, num_read: b.num_read, num_write: b.num_write, ex_data: b.ex_data)

	return 1
}

private func dwrap_free(bio: UnsafeMutablePointer<BIO>?) -> Int32 {
	guard let bio = bio else { return 0 }

	OPENSSL_free(bio.pointee.ptr)

	let b = bio.pointee
	bio.pointee = BIO(method: b.method, callback: b.callback, cb_arg: b.cb_arg, init: 0, shutdown: b.shutdown, flags: 0, retry_reason: b.retry_reason, num: b.num, ptr: nil, next_bio: b.next_bio, prev_bio: b.prev_bio, references: b.references, num_read: b.num_read, num_write: b.num_write, ex_data: b.ex_data)

	return 1
}

private func dwrap_read(bio: UnsafeMutablePointer<BIO>?, data: UnsafeMutablePointer<Int8>?, length: Int32) -> Int32 {
	guard let bio = bio, let data = data else { return 0 }

	BIO_clear_retry_flags(bio)

	let ret = BIO_read(bio.pointee.next_bio, data, length)

	if ret <= 0 {
		BIO_copy_next_retry(bio)
	}

	return ret
}

private func dwrap_write(bio: UnsafeMutablePointer<BIO>?, data: UnsafePointer<Int8>?, length: Int32) -> Int32 {
	guard let bio = bio, let data = data, length > 0 else { return 0 }
	return BIO_write(bio.pointee.next_bio, data, length)
}

private func dwrap_puts(bio: UnsafeMutablePointer<BIO>?, data: UnsafePointer<Int8>?) -> Int32 {
	fatalError()
}

private func dwrap_gets(bio: UnsafeMutablePointer<BIO>?, data: UnsafeMutablePointer<Int8>?, length: Int32) -> Int32 {
	fatalError()
}

private func dwrap_ctrl(bio: UnsafeMutablePointer<BIO>?, cmd: Int32, num: Int, ptr: UnsafeMutableRawPointer?) -> Int {
	let ctx = bio!.pointee.ptr.assumingMemoryBound(to: BIO_F_DWRAP_CTX.self)
	var ret: Int
	switch cmd {
	case BIO_CTRL_DGRAM_GET_RECV_TIMER_EXP:
		if ctx.pointee.dgram_timer_exp {
			ret = 1
			ctx.pointee.dgram_timer_exp = false
		} else {
			ret = 0
		}
	case BIO_CTRL_DGRAM_SET_RECV_TIMEOUT:
		ctx.pointee.dgram_timer_exp = true
		ret = 1
	default:
		ret = BIO_ctrl(bio!.pointee.next_bio, cmd, num, ptr)
	}
	return ret
}
