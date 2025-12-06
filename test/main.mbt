///|
/// Test oracle: Compare MoonBit CBOR implementation with libcbor
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

///|
fn bytes_to_hex(b : Bytes) -> String {
  let hex_chars = "0123456789abcdef"
  let result : Array[Char] = []
  for i = 0; i < b.length(); i = i + 1 {
    let byte = b[i].to_int()
    result.push(hex_chars[byte >> 4].unsafe_to_char())
    result.push(hex_chars[byte & 0x0f].unsafe_to_char())
    if i < b.length() - 1 {
      result.push(' ')
    }
  }
  String::from_array(result)
}

///|
fn test_int(value : Int64) -> Bool {
  let moonbit_result = @cbor_pure.encode_int(value)
  let oracle_result = oracle_encode_int(value)
  let equal = bytes_equal(moonbit_result, oracle_result)
  if not(equal) {
    println("FAIL: encode_int(\{value})")
    println("  MoonBit: \{bytes_to_hex(moonbit_result)}")
    println("  Oracle:  \{bytes_to_hex(oracle_result)}")
  }
  equal
}

///|
fn test_double(value : Double) -> Bool {
  let moonbit_result = @cbor_pure.encode_double(value)
  let oracle_result = oracle_encode_double(value)
  let equal = bytes_equal(moonbit_result, oracle_result)
  if not(equal) {
    println("FAIL: encode_double(\{value})")
    println("  MoonBit: \{bytes_to_hex(moonbit_result)}")
    println("  Oracle:  \{bytes_to_hex(oracle_result)}")
  }
  equal
}

///|
fn test_string(value : String) -> Bool {
  // Convert string to UTF-8 bytes for oracle
  let utf8_bytes = string_to_utf8(value)
  let moonbit_result = @cbor_pure.encode_string(value)
  let oracle_result = oracle_encode_string(utf8_bytes, utf8_bytes.length())
  let equal = bytes_equal(moonbit_result, oracle_result)
  if not(equal) {
    println("FAIL: encode_string(\"\{value}\")")
    println("  MoonBit: \{bytes_to_hex(moonbit_result)}")
    println("  Oracle:  \{bytes_to_hex(oracle_result)}")
  }
  equal
}

///|
fn string_to_utf8(s : String) -> Bytes {
  let result : Array[Byte] = []
  for c in s {
    let code = c.to_int()
    if code < 0x80 {
      result.push(code.to_byte())
    } else if code < 0x800 {
      result.push(((code >> 6) | 0xC0).to_byte())
      result.push(((code & 0x3F) | 0x80).to_byte())
    } else if code < 0x10000 {
      result.push(((code >> 12) | 0xE0).to_byte())
      result.push((((code >> 6) & 0x3F) | 0x80).to_byte())
      result.push(((code & 0x3F) | 0x80).to_byte())
    } else {
      result.push(((code >> 18) | 0xF0).to_byte())
      result.push((((code >> 12) & 0x3F) | 0x80).to_byte())
      result.push((((code >> 6) & 0x3F) | 0x80).to_byte())
      result.push(((code & 0x3F) | 0x80).to_byte())
    }
  }
  Bytes::from_array(result)
}

///|
fn test_bytes(value : Bytes) -> Bool {
  let moonbit_result = @cbor_pure.encode_bytes(value)
  let oracle_result = oracle_encode_bytes(value, value.length())
  let equal = bytes_equal(moonbit_result, oracle_result)
  if not(equal) {
    println("FAIL: encode_bytes")
    println("  MoonBit: \{bytes_to_hex(moonbit_result)}")
    println("  Oracle:  \{bytes_to_hex(oracle_result)}")
  }
  equal
}

///|
fn test_bool(value : Bool) -> Bool {
  let moonbit_result = @cbor_pure.encode_bool(value)
  let oracle_result = oracle_encode_bool(if value { 1 } else { 0 })
  let equal = bytes_equal(moonbit_result, oracle_result)
  if not(equal) {
    println("FAIL: encode_bool(\{value})")
    println("  MoonBit: \{bytes_to_hex(moonbit_result)}")
    println("  Oracle:  \{bytes_to_hex(oracle_result)}")
  }
  equal
}

///|
fn test_null() -> Bool {
  let moonbit_result = @cbor_pure.encode_null()
  let oracle_result = oracle_encode_null()
  let equal = bytes_equal(moonbit_result, oracle_result)
  if not(equal) {
    println("FAIL: encode_null()")
    println("  MoonBit: \{bytes_to_hex(moonbit_result)}")
    println("  Oracle:  \{bytes_to_hex(oracle_result)}")
  }
  equal
}

///|
fn main {
  println("=== CBOR Test Oracle ===")
  println("Comparing MoonBit implementation with libcbor\n")
  let mut passed = 0
  let mut failed = 0

  // Test integers
  println("Testing integers...")
  let int_tests : Array[Int64] = [
    0L, 1L, 23L, 24L, 255L, 256L, 65535L, 65536L, 4294967295L, 4294967296L, 12345678901234L,
    -1L, -10L, -24L, -25L, -100L, -1000L, -1000000L,
  ]
  for v in int_tests {
    if test_int(v) {
      passed = passed + 1
    } else {
      failed = failed + 1
    }
  }

  // Test doubles
  println("Testing doubles...")
  let double_tests : Array[Double] = [
    0.0, 1.0, -1.0, 3.141592653589793, 1.0e10, 1.0e-10, @double.infinity, @double.neg_infinity,
  ]
  for v in double_tests {
    if test_double(v) {
      passed = passed + 1
    } else {
      failed = failed + 1
    }
  }

  // Test strings
  println("Testing strings...")
  let string_tests : Array[String] = [
    "", "a", "hello", "Hello, CBOR!", "こんにちは", "Hello, CBOR! こんにちは",
    "🎉", "emoji: 🚀🌟",
  ]
  for v in string_tests {
    if test_string(v) {
      passed = passed + 1
    } else {
      failed = failed + 1
    }
  }

  // Test bytes
  println("Testing bytes...")
  let bytes_tests : Array[Bytes] = [
    Bytes::from_array([]),
    Bytes::from_array([b'\x00']),
    Bytes::from_array([b'\x01', b'\x02', b'\x03', b'\x04', b'\x05']),
    Bytes::from_array([b'\xff', b'\xfe', b'\xfd']),
  ]
  for v in bytes_tests {
    if test_bytes(v) {
      passed = passed + 1
    } else {
      failed = failed + 1
    }
  }

  // Test booleans
  println("Testing booleans...")
  if test_bool(true) {
    passed = passed + 1
  } else {
    failed = failed + 1
  }
  if test_bool(false) {
    passed = passed + 1
  } else {
    failed = failed + 1
  }

  // Test null
  println("Testing null...")
  if test_null() {
    passed = passed + 1
  } else {
    failed = failed + 1
  }

  // Summary
  println("\n=== Results ===")
  println("Passed: \{passed}")
  println("Failed: \{failed}")
  if failed == 0 {
    println("\n✓ All tests passed!")
  } else {
    println("\n✗ Some tests failed")
  }
}
