///|
/// High-level CBOR API

///|
/// CBOR エンコード/デコードエラー
pub suberror CborError String

///|
/// Int64 を CBOR にエンコード
pub fn encode_int(value : Int64) -> Bytes raise CborError {
  let result = CborResult::new()
  cbor_init_result(result)
  let status = cbor_encode_int_ffi(value, result)
  if status != 0 {
    cbor_result_free(result)
    raise CborError("Failed to encode int")
  }
  let output = cbor_result_to_bytes(result)
  cbor_result_free(result)
  output
}

///|
/// CBOR から Int64 をデコード
pub fn decode_int(input : Bytes) -> Int64 raise CborError {
  let value : FixedArray[Int64] = [0L]
  let status = cbor_decode_int_ffi(input, input.length(), value)
  if status != 0 {
    raise CborError("Failed to decode int")
  }
  value[0]
}

///|
/// Double を CBOR にエンコード
pub fn encode_double(value : Double) -> Bytes raise CborError {
  let result = CborResult::new()
  cbor_init_result(result)
  let status = cbor_encode_double_ffi(value, result)
  if status != 0 {
    cbor_result_free(result)
    raise CborError("Failed to encode double")
  }
  let output = cbor_result_to_bytes(result)
  cbor_result_free(result)
  output
}

///|
/// CBOR から Double をデコード
pub fn decode_double(input : Bytes) -> Double raise CborError {
  let value : FixedArray[Double] = [0.0]
  let status = cbor_decode_double_ffi(input, input.length(), value)
  if status != 0 {
    raise CborError("Failed to decode double")
  }
  value[0]
}

///|
/// String を CBOR にエンコード
pub fn encode_string(value : String) -> Bytes raise CborError {
  let utf8 = string_to_utf8(value)
  let result = CborResult::new()
  cbor_init_result(result)
  let status = cbor_encode_string_ffi(utf8, utf8.length(), result)
  if status != 0 {
    cbor_result_free(result)
    raise CborError("Failed to encode string")
  }
  let output = cbor_result_to_bytes(result)
  cbor_result_free(result)
  output
}

///|
/// CBOR から String をデコード
pub fn decode_string(input : Bytes) -> String raise CborError {
  let result = CborResult::new()
  cbor_init_result(result)
  let status = cbor_decode_string_ffi(input, input.length(), result)
  if status != 0 {
    cbor_result_free(result)
    raise CborError("Failed to decode string")
  }
  let utf8 = cbor_result_to_bytes(result)
  cbor_result_free(result)
  utf8_to_string(utf8)
}

///|
/// Bytes を CBOR にエンコード
pub fn encode_bytes(value : Bytes) -> Bytes raise CborError {
  let result = CborResult::new()
  cbor_init_result(result)
  let status = cbor_encode_bytes_ffi(value, value.length(), result)
  if status != 0 {
    cbor_result_free(result)
    raise CborError("Failed to encode bytes")
  }
  let output = cbor_result_to_bytes(result)
  cbor_result_free(result)
  output
}

///|
/// CBOR から Bytes をデコード
pub fn decode_bytes(input : Bytes) -> Bytes raise CborError {
  let result = CborResult::new()
  cbor_init_result(result)
  let status = cbor_decode_bytes_ffi(input, input.length(), result)
  if status != 0 {
    cbor_result_free(result)
    raise CborError("Failed to decode bytes")
  }
  let output = cbor_result_to_bytes(result)
  cbor_result_free(result)
  output
}

///|
/// Bool を CBOR にエンコード
pub fn encode_bool(value : Bool) -> Bytes raise CborError {
  let result = CborResult::new()
  cbor_init_result(result)
  let int_val = if value { 1 } else { 0 }
  let status = cbor_encode_bool_ffi(int_val, result)
  if status != 0 {
    cbor_result_free(result)
    raise CborError("Failed to encode bool")
  }
  let output = cbor_result_to_bytes(result)
  cbor_result_free(result)
  output
}

///|
/// CBOR から Bool をデコード
pub fn decode_bool(input : Bytes) -> Bool raise CborError {
  let value : FixedArray[Int] = [0]
  let status = cbor_decode_bool_ffi(input, input.length(), value)
  if status != 0 {
    raise CborError("Failed to decode bool")
  }
  value[0] != 0
}

///|
/// Null を CBOR にエンコード
pub fn encode_null() -> Bytes raise CborError {
  let result = CborResult::new()
  cbor_init_result(result)
  let status = cbor_encode_null_ffi(result)
  if status != 0 {
    cbor_result_free(result)
    raise CborError("Failed to encode null")
  }
  let output = cbor_result_to_bytes(result)
  cbor_result_free(result)
  output
}

///|
/// 文字列を UTF-8 バイト列に変換
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
/// UTF-8 バイト列を文字列に変換
fn utf8_to_string(bytes : Bytes) -> String {
  let result : Array[Char] = []
  let mut i = 0
  while i < bytes.length() {
    let b0 = bytes[i].to_int()
    if b0 < 0x80 {
      result.push(Char::from_int(b0))
      i = i + 1
    } else if b0 < 0xE0 {
      let b1 = bytes[i + 1].to_int()
      let code = ((b0 & 0x1F) << 6) | (b1 & 0x3F)
      result.push(Char::from_int(code))
      i = i + 2
    } else if b0 < 0xF0 {
      let b1 = bytes[i + 1].to_int()
      let b2 = bytes[i + 2].to_int()
      let code = ((b0 & 0x0F) << 12) | ((b1 & 0x3F) << 6) | (b2 & 0x3F)
      result.push(Char::from_int(code))
      i = i + 3
    } else {
      let b1 = bytes[i + 1].to_int()
      let b2 = bytes[i + 2].to_int()
      let b3 = bytes[i + 3].to_int()
      let code = ((b0 & 0x07) << 18) |
        ((b1 & 0x3F) << 12) |
        ((b2 & 0x3F) << 6) |
        (b3 & 0x3F)
      result.push(Char::from_int(code))
      i = i + 4
    }
  }
  String::from_array(result)
}
