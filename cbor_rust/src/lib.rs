//! CBOR serialization library for MoonBit FFI
//!
//! Provides basic CBOR encoding/decoding operations via C FFI.

use std::ffi::c_int;
use std::io::Cursor;

/// Result structure for CBOR operations
#[repr(C)]
pub struct CborResult {
    pub data: *mut u8,
    pub len: usize,
    pub error: c_int,
}

/// Initialize a result structure
#[no_mangle]
pub unsafe extern "C" fn cbor_init_result(result: *mut CborResult) {
    if !result.is_null() {
        (*result).data = std::ptr::null_mut();
        (*result).len = 0;
        (*result).error = 0;
    }
}

/// Free memory allocated for result
#[no_mangle]
pub unsafe extern "C" fn cbor_free(ptr: *mut u8, len: usize) {
    if !ptr.is_null() && len > 0 {
        let _ = Vec::from_raw_parts(ptr, len, len);
    }
}

/// Encode an integer to CBOR
#[no_mangle]
pub unsafe extern "C" fn cbor_encode_int(value: i64, result: *mut CborResult) -> c_int {
    if result.is_null() {
        return -1;
    }

    let mut buffer = Vec::new();
    match ciborium::into_writer(&value, &mut buffer) {
        Ok(()) => {
            let len = buffer.len();
            let ptr = buffer.as_mut_ptr();
            std::mem::forget(buffer);
            (*result).data = ptr;
            (*result).len = len;
            (*result).error = 0;
            0
        }
        Err(_) => {
            (*result).error = 1;
            -1
        }
    }
}

/// Decode CBOR to integer
#[no_mangle]
pub unsafe extern "C" fn cbor_decode_int(
    input: *const u8,
    input_len: usize,
    value: *mut i64,
) -> c_int {
    if input.is_null() || value.is_null() || input_len == 0 {
        return -1;
    }

    let slice = std::slice::from_raw_parts(input, input_len);
    let cursor = Cursor::new(slice);

    match ciborium::from_reader::<i64, _>(cursor) {
        Ok(v) => {
            *value = v;
            0
        }
        Err(_) => -1,
    }
}

/// Encode a double to CBOR
#[no_mangle]
pub unsafe extern "C" fn cbor_encode_double(value: f64, result: *mut CborResult) -> c_int {
    if result.is_null() {
        return -1;
    }

    let mut buffer = Vec::new();
    match ciborium::into_writer(&value, &mut buffer) {
        Ok(()) => {
            let len = buffer.len();
            let ptr = buffer.as_mut_ptr();
            std::mem::forget(buffer);
            (*result).data = ptr;
            (*result).len = len;
            (*result).error = 0;
            0
        }
        Err(_) => {
            (*result).error = 1;
            -1
        }
    }
}

/// Decode CBOR to double
#[no_mangle]
pub unsafe extern "C" fn cbor_decode_double(
    input: *const u8,
    input_len: usize,
    value: *mut f64,
) -> c_int {
    if input.is_null() || value.is_null() || input_len == 0 {
        return -1;
    }

    let slice = std::slice::from_raw_parts(input, input_len);
    let cursor = Cursor::new(slice);

    match ciborium::from_reader::<f64, _>(cursor) {
        Ok(v) => {
            *value = v;
            0
        }
        Err(_) => -1,
    }
}

/// Encode a string to CBOR
#[no_mangle]
pub unsafe extern "C" fn cbor_encode_string(
    input: *const u8,
    input_len: usize,
    result: *mut CborResult,
) -> c_int {
    if input.is_null() || result.is_null() {
        return -1;
    }

    let slice = std::slice::from_raw_parts(input, input_len);
    let s = match std::str::from_utf8(slice) {
        Ok(s) => s,
        Err(_) => {
            (*result).error = 2; // UTF-8 error
            return -1;
        }
    };

    let mut buffer = Vec::new();
    match ciborium::into_writer(&s, &mut buffer) {
        Ok(()) => {
            let len = buffer.len();
            let ptr = buffer.as_mut_ptr();
            std::mem::forget(buffer);
            (*result).data = ptr;
            (*result).len = len;
            (*result).error = 0;
            0
        }
        Err(_) => {
            (*result).error = 1;
            -1
        }
    }
}

/// Decode CBOR to string, returns the length of the decoded string
#[no_mangle]
pub unsafe extern "C" fn cbor_decode_string(
    input: *const u8,
    input_len: usize,
    result: *mut CborResult,
) -> c_int {
    if input.is_null() || result.is_null() || input_len == 0 {
        return -1;
    }

    let slice = std::slice::from_raw_parts(input, input_len);
    let cursor = Cursor::new(slice);

    match ciborium::from_reader::<String, _>(cursor) {
        Ok(s) => {
            let bytes = s.into_bytes();
            let len = bytes.len();
            let mut boxed = bytes.into_boxed_slice();
            let ptr = boxed.as_mut_ptr();
            std::mem::forget(boxed);
            (*result).data = ptr;
            (*result).len = len;
            (*result).error = 0;
            0
        }
        Err(_) => {
            (*result).error = 1;
            -1
        }
    }
}

/// Encode bytes to CBOR
#[no_mangle]
pub unsafe extern "C" fn cbor_encode_bytes(
    input: *const u8,
    input_len: usize,
    result: *mut CborResult,
) -> c_int {
    if input.is_null() || result.is_null() {
        return -1;
    }

    let slice = std::slice::from_raw_parts(input, input_len);
    let bytes = ciborium::value::Value::Bytes(slice.to_vec());

    let mut buffer = Vec::new();
    match ciborium::into_writer(&bytes, &mut buffer) {
        Ok(()) => {
            let len = buffer.len();
            let ptr = buffer.as_mut_ptr();
            std::mem::forget(buffer);
            (*result).data = ptr;
            (*result).len = len;
            (*result).error = 0;
            0
        }
        Err(_) => {
            (*result).error = 1;
            -1
        }
    }
}

/// Decode CBOR bytes
#[no_mangle]
pub unsafe extern "C" fn cbor_decode_bytes(
    input: *const u8,
    input_len: usize,
    result: *mut CborResult,
) -> c_int {
    if input.is_null() || result.is_null() || input_len == 0 {
        return -1;
    }

    let slice = std::slice::from_raw_parts(input, input_len);
    let cursor = Cursor::new(slice);

    match ciborium::from_reader::<ciborium::value::Value, _>(cursor) {
        Ok(ciborium::value::Value::Bytes(bytes)) => {
            let len = bytes.len();
            let mut boxed = bytes.into_boxed_slice();
            let ptr = boxed.as_mut_ptr();
            std::mem::forget(boxed);
            (*result).data = ptr;
            (*result).len = len;
            (*result).error = 0;
            0
        }
        _ => {
            (*result).error = 1;
            -1
        }
    }
}

/// Encode a boolean to CBOR
#[no_mangle]
pub unsafe extern "C" fn cbor_encode_bool(value: c_int, result: *mut CborResult) -> c_int {
    if result.is_null() {
        return -1;
    }

    let b = value != 0;
    let mut buffer = Vec::new();
    match ciborium::into_writer(&b, &mut buffer) {
        Ok(()) => {
            let len = buffer.len();
            let ptr = buffer.as_mut_ptr();
            std::mem::forget(buffer);
            (*result).data = ptr;
            (*result).len = len;
            (*result).error = 0;
            0
        }
        Err(_) => {
            (*result).error = 1;
            -1
        }
    }
}

/// Decode CBOR to boolean
#[no_mangle]
pub unsafe extern "C" fn cbor_decode_bool(
    input: *const u8,
    input_len: usize,
    value: *mut c_int,
) -> c_int {
    if input.is_null() || value.is_null() || input_len == 0 {
        return -1;
    }

    let slice = std::slice::from_raw_parts(input, input_len);
    let cursor = Cursor::new(slice);

    match ciborium::from_reader::<bool, _>(cursor) {
        Ok(v) => {
            *value = if v { 1 } else { 0 };
            0
        }
        Err(_) => -1,
    }
}

/// Encode null to CBOR
#[no_mangle]
pub unsafe extern "C" fn cbor_encode_null(result: *mut CborResult) -> c_int {
    if result.is_null() {
        return -1;
    }

    let null = ciborium::value::Value::Null;
    let mut buffer = Vec::new();
    match ciborium::into_writer(&null, &mut buffer) {
        Ok(()) => {
            let len = buffer.len();
            let ptr = buffer.as_mut_ptr();
            std::mem::forget(buffer);
            (*result).data = ptr;
            (*result).len = len;
            (*result).error = 0;
            0
        }
        Err(_) => {
            (*result).error = 1;
            -1
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encode_decode_int() {
        unsafe {
            let mut result = CborResult {
                data: std::ptr::null_mut(),
                len: 0,
                error: 0,
            };

            assert_eq!(cbor_encode_int(42, &mut result), 0);
            assert!(!result.data.is_null());

            let mut decoded: i64 = 0;
            assert_eq!(cbor_decode_int(result.data, result.len, &mut decoded), 0);
            assert_eq!(decoded, 42);

            cbor_free(result.data, result.len);
        }
    }

    #[test]
    fn test_encode_decode_string() {
        unsafe {
            let mut result = CborResult {
                data: std::ptr::null_mut(),
                len: 0,
                error: 0,
            };

            let s = "Hello, CBOR!";
            assert_eq!(cbor_encode_string(s.as_ptr(), s.len(), &mut result), 0);

            let mut decoded_result = CborResult {
                data: std::ptr::null_mut(),
                len: 0,
                error: 0,
            };
            assert_eq!(cbor_decode_string(result.data, result.len, &mut decoded_result), 0);

            let decoded = std::str::from_utf8(
                std::slice::from_raw_parts(decoded_result.data, decoded_result.len)
            ).unwrap();
            assert_eq!(decoded, s);

            cbor_free(result.data, result.len);
            cbor_free(decoded_result.data, decoded_result.len);
        }
    }
}
