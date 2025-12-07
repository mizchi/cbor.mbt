///|
/// CBOR Test Suite
/// Tests encoding/decoding and validates against RFC 8949 examples

// Helper functions

///|
fn bytes_equal(a : Bytes, b : Bytes) -> Bool {
  if a.length() != b.length() {
    return false
  }
  for i = 0; i < a.length(); i = i + 1 {
    if a[i] != b[i] {
      return false
    }
  }
  true
}

// RFC 8949 Appendix A Examples

test "encode_int: small positive integers (RFC 8949)" {
  // 0 → 0x00
  assert_eq(encode_int(0L), Bytes::from_array([b'\x00']))
  // 1 → 0x01
  assert_eq(encode_int(1L), Bytes::from_array([b'\x01']))
  // 10 → 0x0a
  assert_eq(encode_int(10L), Bytes::from_array([b'\x0a']))
  // 23 → 0x17
  assert_eq(encode_int(23L), Bytes::from_array([b'\x17']))
}

test "encode_int: uint8 range (RFC 8949)" {
  // 24 → 0x18 0x18
  assert_eq(encode_int(24L), Bytes::from_array([b'\x18', b'\x18']))
  // 25 → 0x18 0x19
  assert_eq(encode_int(25L), Bytes::from_array([b'\x18', b'\x19']))
  // 100 → 0x18 0x64
  assert_eq(encode_int(100L), Bytes::from_array([b'\x18', b'\x64']))
}

test "encode_int: uint16 range (RFC 8949)" {
  // 1000 → 0x19 0x03e8
  assert_eq(encode_int(1000L), Bytes::from_array([b'\x19', b'\x03', b'\xe8']))
}

test "encode_int: uint32 range (RFC 8949)" {
  // 1000000 → 0x1a 0x000f4240
  assert_eq(
    encode_int(1000000L),
    Bytes::from_array([b'\x1a', b'\x00', b'\x0f', b'\x42', b'\x40']),
  )
}

test "encode_int: uint64 range (RFC 8949)" {
  // 1000000000000 → 0x1b 0x000000e8d4a51000
  assert_eq(
    encode_int(1000000000000L),
    Bytes::from_array([
      b'\x1b', b'\x00', b'\x00', b'\x00', b'\xe8', b'\xd4', b'\xa5', b'\x10', b'\x00',
    ]),
  )
}

test "encode_int: negative integers (RFC 8949)" {
  // -1 → 0x20
  assert_eq(encode_int(-1L), Bytes::from_array([b'\x20']))
  // -10 → 0x29
  assert_eq(encode_int(-10L), Bytes::from_array([b'\x29']))
  // -100 → 0x38 0x63
  assert_eq(encode_int(-100L), Bytes::from_array([b'\x38', b'\x63']))
  // -1000 → 0x39 0x03e7
  assert_eq(encode_int(-1000L), Bytes::from_array([b'\x39', b'\x03', b'\xe7']))
}

test "encode_string: empty and simple strings (RFC 8949)" {
  // "" → 0x60
  assert_eq(encode_string(""), Bytes::from_array([b'\x60']))
  // "a" → 0x61 0x61
  assert_eq(encode_string("a"), Bytes::from_array([b'\x61', b'\x61']))
  // "IETF" → 0x64 "IETF"
  assert_eq(
    encode_string("IETF"),
    Bytes::from_array([b'\x64', b'\x49', b'\x45', b'\x54', b'\x46']),
  )
}

test "encode_string: unicode strings" {
  // Test Japanese characters
  let encoded = encode_string("こんにちは")
  let decoded = decode_string(encoded)
  assert_eq(decoded, "こんにちは")

  // Test emoji
  let encoded_emoji = encode_string("🎉")
  let decoded_emoji = decode_string(encoded_emoji)
  assert_eq(decoded_emoji, "🎉")
}

test "encode_bytes: various byte strings (RFC 8949)" {
  // h'' → 0x40
  assert_eq(encode_bytes(Bytes::from_array([])), Bytes::from_array([b'\x40']))

  // h'01020304' → 0x44 0x01020304
  assert_eq(
    encode_bytes(Bytes::from_array([b'\x01', b'\x02', b'\x03', b'\x04'])),
    Bytes::from_array([b'\x44', b'\x01', b'\x02', b'\x03', b'\x04']),
  )
}

test "encode_bool: true and false (RFC 8949)" {
  // false → 0xf4
  assert_eq(encode_bool(false), Bytes::from_array([b'\xf4']))
  // true → 0xf5
  assert_eq(encode_bool(true), Bytes::from_array([b'\xf5']))
}

test "encode_null: null value (RFC 8949)" {
  // null → 0xf6
  assert_eq(encode_null(), Bytes::from_array([b'\xf6']))
}

test "encode_double: special float values (RFC 8949)" {
  // 0.0 → 0xfb 0x0000000000000000
  let zero = encode_double(0.0)
  assert_eq(zero.length(), 9)
  assert_eq(zero[0], b'\xfb')

  // Test decode roundtrip
  assert_eq(decode_double(zero), 0.0)

  // 1.0
  let one = encode_double(1.0)
  assert_eq(decode_double(one), 1.0)

  // -1.0
  let neg_one = encode_double(-1.0)
  assert_eq(decode_double(neg_one), -1.0)
}

// Roundtrip tests

test "roundtrip: integers" {
  let test_values : Array[Int64] = [
    0L, 1L, 23L, 24L, 255L, 256L, 65535L, 65536L, 4294967295L, 4294967296L,
    -1L, -10L, -24L, -25L, -100L, -1000L, -1000000L,
  ]

  for v in test_values {
    let encoded = encode_int(v)
    let decoded = decode_int(encoded)
    if decoded != v {
      abort("Roundtrip failed for \{v}: got \{decoded}")
    }
  }
}

test "roundtrip: doubles" {
  let test_values : Array[Double] = [
    0.0, 1.0, -1.0, 3.141592653589793, 1.0e10, 1.0e-10,
  ]

  for v in test_values {
    let encoded = encode_double(v)
    let decoded = decode_double(encoded)
    if decoded != v {
      abort("Roundtrip failed for \{v}: got \{decoded}")
    }
  }
}

test "roundtrip: infinity values" {
  let inf = @double.infinity
  let encoded_inf = encode_double(inf)
  let decoded_inf = decode_double(encoded_inf)
  assert_true(decoded_inf == inf)

  let neg_inf = @double.neg_infinity
  let encoded_neg_inf = encode_double(neg_inf)
  let decoded_neg_inf = decode_double(encoded_neg_inf)
  assert_true(decoded_neg_inf == neg_inf)
}

test "roundtrip: strings" {
  let test_values : Array[String] = [
    "", "a", "hello", "Hello, CBOR!", "こんにちは", "Hello, CBOR! こんにちは",
    "🎉", "emoji: 🚀🌟",
  ]

  for v in test_values {
    let encoded = encode_string(v)
    let decoded = decode_string(encoded)
    assert_eq(decoded, v)
  }
}

test "roundtrip: bytes" {
  let test_values : Array[Bytes] = [
    Bytes::from_array([]),
    Bytes::from_array([b'\x00']),
    Bytes::from_array([b'\x01', b'\x02', b'\x03', b'\x04', b'\x05']),
    Bytes::from_array([b'\xff', b'\xfe', b'\xfd']),
  ]

  for v in test_values {
    let encoded = encode_bytes(v)
    let decoded = decode_bytes(encoded)
    assert_true(bytes_equal(decoded, v))
  }
}

test "roundtrip: booleans" {
  let encoded_true = encode_bool(true)
  let decoded_true = decode_bool(encoded_true)
  assert_eq(decoded_true, true)

  let encoded_false = encode_bool(false)
  let decoded_false = decode_bool(encoded_false)
  assert_eq(decoded_false, false)
}

// Edge cases

test "edge_case: large integers" {
  let max_u32 = 4294967295L
  let encoded = encode_int(max_u32)
  let decoded = decode_int(encoded)
  assert_eq(decoded, max_u32)

  let large = 12345678901234L
  let encoded_large = encode_int(large)
  let decoded_large = decode_int(encoded_large)
  assert_eq(decoded_large, large)
}

test "edge_case: boundary values for encoding formats" {
  // Test boundary between different encoding formats

  // 23 (last inline value)
  let v23 = encode_int(23L)
  assert_eq(v23.length(), 1)

  // 24 (first uint8 value)
  let v24 = encode_int(24L)
  assert_eq(v24.length(), 2)

  // 255 (last uint8 value)
  let v255 = encode_int(255L)
  assert_eq(v255.length(), 2)

  // 256 (first uint16 value)
  let v256 = encode_int(256L)
  assert_eq(v256.length(), 3)
}

test "edge_case: empty strings and bytes" {
  // Empty string
  let empty_str = encode_string("")
  assert_eq(empty_str.length(), 1)
  assert_eq(decode_string(empty_str), "")

  // Empty bytes
  let empty_bytes = encode_bytes(Bytes::from_array([]))
  assert_eq(empty_bytes.length(), 1)
  assert_true(bytes_equal(decode_bytes(empty_bytes), Bytes::from_array([])))
}

test "edge_case: string length boundaries" {
  // 23 character string (inline length)
  let s23 = "a".repeat(23)
  let e23 = encode_string(s23)
  assert_eq(decode_string(e23), s23)

  // 24 character string (uint8 length)
  let s24 = "a".repeat(24)
  let e24 = encode_string(s24)
  assert_eq(decode_string(e24), s24)
}
