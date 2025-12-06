///|
test "encode_int" (bench : @bench.T) {
  bench.bench(fn() {
    let _ = encode_int(12345678901234L) catch { _ => Bytes::new(0) }

  })
}

///|
test "decode_int" (bench : @bench.T) {
  let encoded = encode_int(12345678901234L) catch { _ => Bytes::new(0) }
  bench.bench(fn() {
    let _ = decode_int(encoded) catch { _ => 0L }

  })
}

///|
test "encode_double" (bench : @bench.T) {
  bench.bench(fn() {
    let _ = encode_double(3.141592653589793) catch { _ => Bytes::new(0) }

  })
}

///|
test "decode_double" (bench : @bench.T) {
  let encoded = encode_double(3.141592653589793) catch { _ => Bytes::new(0) }
  bench.bench(fn() {
    let _ = decode_double(encoded) catch { _ => 0.0 }

  })
}

///|
test "encode_string" (bench : @bench.T) {
  bench.bench(fn() {
    let _ = encode_string("Hello, CBOR! こんにちは") catch {
      _ => Bytes::new(0)
    }

  })
}

///|
test "decode_string" (bench : @bench.T) {
  let encoded = encode_string("Hello, CBOR! こんにちは") catch {
    _ => Bytes::new(0)
  }
  bench.bench(fn() {
    let _ = decode_string(encoded) catch { _ => "" }

  })
}

///|
test "encode_bytes" (bench : @bench.T) {
  let data = Bytes::from_array([b'\x01', b'\x02', b'\x03', b'\x04', b'\x05'])
  bench.bench(fn() {
    let _ = encode_bytes(data) catch { _ => Bytes::new(0) }

  })
}

///|
test "decode_bytes" (bench : @bench.T) {
  let data = Bytes::from_array([b'\x01', b'\x02', b'\x03', b'\x04', b'\x05'])
  let encoded = encode_bytes(data) catch { _ => Bytes::new(0) }
  bench.bench(fn() {
    let _ = decode_bytes(encoded) catch { _ => Bytes::new(0) }

  })
}

///|
test "encode_bool" (bench : @bench.T) {
  bench.bench(fn() {
    let _ = encode_bool(true) catch { _ => Bytes::new(0) }

  })
}

///|
test "decode_bool" (bench : @bench.T) {
  let encoded = encode_bool(true) catch { _ => Bytes::new(0) }
  bench.bench(fn() {
    let _ = decode_bool(encoded) catch { _ => false }

  })
}
