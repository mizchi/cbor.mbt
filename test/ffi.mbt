///|
/// FFI declarations for libcbor test oracle functions

///|
/// Encode int64 using libcbor (reference implementation)
extern "C" fn oracle_encode_int(value : Int64) -> Bytes = "oracle_encode_int"

///|
/// Encode double using libcbor
extern "C" fn oracle_encode_double(value : Double) -> Bytes = "oracle_encode_double"

///|
/// Encode string using libcbor
extern "C" fn oracle_encode_string(input : Bytes, input_len : Int) -> Bytes = "oracle_encode_string"

///|
/// Encode bytes using libcbor
extern "C" fn oracle_encode_bytes(input : Bytes, input_len : Int) -> Bytes = "oracle_encode_bytes"

///|
/// Encode bool using libcbor
extern "C" fn oracle_encode_bool(value : Int) -> Bytes = "oracle_encode_bool"

///|
/// Encode null using libcbor
extern "C" fn oracle_encode_null() -> Bytes = "oracle_encode_null"
