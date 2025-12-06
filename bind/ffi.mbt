///|
/// C FFI declarations for cborlib

///|
/// CborResult - エンコード/デコード結果を格納する構造体
pub struct CborResult {
  data_ptr : Int64
  len : Int
  error : Int
}

///|
pub fn CborResult::new() -> CborResult {
  { data_ptr: 0L, len: 0, error: 0 }
}

///|
/// 結果を初期化
#borrow(result)
extern "C" fn cbor_init_result(result : CborResult) = "moonbit_cbor_init_result"

///|
/// 結果を解放
#borrow(result)
extern "C" fn cbor_result_free(result : CborResult) = "moonbit_cbor_result_free"

///|
/// 結果から Bytes を取得
#borrow(result)
extern "C" fn cbor_result_to_bytes(result : CborResult) -> Bytes = "moonbit_cbor_result_to_bytes"

///|
/// Int64 をエンコード
#borrow(result)
extern "C" fn cbor_encode_int_ffi(value : Int64, result : CborResult) -> Int = "moonbit_cbor_encode_int"

///|
/// Int64 をデコード
#borrow(input, value)
extern "C" fn cbor_decode_int_ffi(
  input : Bytes,
  input_len : Int,
  value : FixedArray[Int64],
) -> Int = "moonbit_cbor_decode_int"

///|
/// Double をエンコード
#borrow(result)
extern "C" fn cbor_encode_double_ffi(
  value : Double,
  result : CborResult,
) -> Int = "moonbit_cbor_encode_double"

///|
/// Double をデコード
#borrow(input, value)
extern "C" fn cbor_decode_double_ffi(
  input : Bytes,
  input_len : Int,
  value : FixedArray[Double],
) -> Int = "moonbit_cbor_decode_double"

///|
/// String をエンコード (UTF-8 bytes として渡す)
#borrow(input, result)
extern "C" fn cbor_encode_string_ffi(
  input : Bytes,
  input_len : Int,
  result : CborResult,
) -> Int = "moonbit_cbor_encode_string"

///|
/// String をデコード
#borrow(input, result)
extern "C" fn cbor_decode_string_ffi(
  input : Bytes,
  input_len : Int,
  result : CborResult,
) -> Int = "moonbit_cbor_decode_string"

///|
/// Bytes をエンコード
#borrow(input, result)
extern "C" fn cbor_encode_bytes_ffi(
  input : Bytes,
  input_len : Int,
  result : CborResult,
) -> Int = "moonbit_cbor_encode_bytes"

///|
/// Bytes をデコード
#borrow(input, result)
extern "C" fn cbor_decode_bytes_ffi(
  input : Bytes,
  input_len : Int,
  result : CborResult,
) -> Int = "moonbit_cbor_decode_bytes"

///|
/// Bool をエンコード
#borrow(result)
extern "C" fn cbor_encode_bool_ffi(value : Int, result : CborResult) -> Int = "moonbit_cbor_encode_bool"

///|
/// Bool をデコード
#borrow(input, value)
extern "C" fn cbor_decode_bool_ffi(
  input : Bytes,
  input_len : Int,
  value : FixedArray[Int],
) -> Int = "moonbit_cbor_decode_bool"

///|
/// Null をエンコード
#borrow(result)
extern "C" fn cbor_encode_null_ffi(result : CborResult) -> Int = "moonbit_cbor_encode_null"
