///|
fn main {
  println("=== CBOR (Pure MoonBit) Demo ===")
  println("")

  // Int64 テスト
  println("--- Int64 ---")
  try {
    let original_int : Int64 = 12345678901234L
    let encoded = @cbor.encode_int(original_int)
    println("Original: \{original_int}")
    println("Encoded bytes: \{encoded.length()}")
    let decoded = @cbor.decode_int(encoded)
    println("Decoded: \{decoded}")
    println("Match: \{original_int == decoded}")
  } catch {
    CborError(msg) => println("Error: \{msg}")
  }
  println("")

  // Negative int test
  println("--- Negative Int64 ---")
  try {
    let original_int : Int64 = -9876543210L
    let encoded = @cbor.encode_int(original_int)
    println("Original: \{original_int}")
    println("Encoded bytes: \{encoded.length()}")
    let decoded = @cbor.decode_int(encoded)
    println("Decoded: \{decoded}")
    println("Match: \{original_int == decoded}")
  } catch {
    CborError(msg) => println("Error: \{msg}")
  }
  println("")

  // Double テスト
  println("--- Double ---")
  try {
    let original_double = 3.141592653589793
    let encoded = @cbor.encode_double(original_double)
    println("Original: \{original_double}")
    println("Encoded bytes: \{encoded.length()}")
    let decoded = @cbor.decode_double(encoded)
    println("Decoded: \{decoded}")
    println("Match: \{original_double == decoded}")
  } catch {
    CborError(msg) => println("Error: \{msg}")
  }
  println("")

  // String テスト
  println("--- String ---")
  try {
    let original_string = "Hello, CBOR! こんにちは"
    let encoded = @cbor.encode_string(original_string)
    println("Original: \{original_string}")
    println("Encoded bytes: \{encoded.length()}")
    let decoded = @cbor.decode_string(encoded)
    println("Decoded: \{decoded}")
    println("Match: \{original_string == decoded}")
  } catch {
    CborError(msg) => println("Error: \{msg}")
  }
  println("")

  // Bool テスト
  println("--- Bool ---")
  try {
    let original_bool = true
    let encoded = @cbor.encode_bool(original_bool)
    println("Original: \{original_bool}")
    println("Encoded bytes: \{encoded.length()}")
    let decoded = @cbor.decode_bool(encoded)
    println("Decoded: \{decoded}")
    println("Match: \{original_bool == decoded}")
  } catch {
    CborError(msg) => println("Error: \{msg}")
  }
  println("")

  // Bytes テスト
  println("--- Bytes ---")
  try {
    let original_bytes = Bytes::from_array([
      b'\x01', b'\x02', b'\x03', b'\x04', b'\x05',
    ])
    let encoded = @cbor.encode_bytes(original_bytes)
    println("Original length: \{original_bytes.length()}")
    println("Encoded bytes: \{encoded.length()}")
    let decoded = @cbor.decode_bytes(encoded)
    println("Decoded length: \{decoded.length()}")
    let mut match_ = original_bytes.length() == decoded.length()
    if match_ {
      for i = 0; i < original_bytes.length(); i = i + 1 {
        if original_bytes[i] != decoded[i] {
          match_ = false
          break
        }
      }
    }
    println("Match: \{match_}")
  } catch {
    CborError(msg) => println("Error: \{msg}")
  }
  println("")

  // Null テスト
  println("--- Null ---")
  let encoded = @cbor.encode_null()
  println("Null encoded bytes: \{encoded.length()}")
  println("")
  println("=== Demo Complete ===")
}
