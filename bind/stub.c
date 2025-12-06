// C wrapper for cborlib Rust functions

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <moonbit.h>

#ifdef __APPLE__
#include <mach/mach_time.h>
#endif

int64_t moonbit_get_time_ns(void) {
#ifdef __APPLE__
    static mach_timebase_info_data_t timebase_info;
    if (timebase_info.denom == 0) {
        mach_timebase_info(&timebase_info);
    }
    uint64_t time = mach_absolute_time();
    return (int64_t)(time * timebase_info.numer / timebase_info.denom);
#else
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (int64_t)ts.tv_sec * 1000000000LL + (int64_t)ts.tv_nsec;
#endif
}

#ifdef __cplusplus
extern "C" {
#endif

// Rust 側の構造体
struct RustCborResult {
    uint8_t* data;
    size_t len;
    int32_t error;
};

// MoonBit 側の構造体 (ffi.mbt の CborResult と対応)
struct $CborResult {
    int64_t data_ptr;
    int32_t len;
    int32_t error;
};

// Rust 側の関数宣言
extern void cbor_init_result(struct RustCborResult* result);
extern void cbor_free(uint8_t* ptr, size_t len);
extern int32_t cbor_encode_int(int64_t value, struct RustCborResult* result);
extern int32_t cbor_decode_int(const uint8_t* input, size_t input_len, int64_t* value);
extern int32_t cbor_encode_double(double value, struct RustCborResult* result);
extern int32_t cbor_decode_double(const uint8_t* input, size_t input_len, double* value);
extern int32_t cbor_encode_string(const uint8_t* input, size_t input_len, struct RustCborResult* result);
extern int32_t cbor_decode_string(const uint8_t* input, size_t input_len, struct RustCborResult* result);
extern int32_t cbor_encode_bytes(const uint8_t* input, size_t input_len, struct RustCborResult* result);
extern int32_t cbor_decode_bytes(const uint8_t* input, size_t input_len, struct RustCborResult* result);
extern int32_t cbor_encode_bool(int32_t value, struct RustCborResult* result);
extern int32_t cbor_decode_bool(const uint8_t* input, size_t input_len, int32_t* value);
extern int32_t cbor_encode_null(struct RustCborResult* result);

// MoonBit から呼ばれるラッパー関数

void moonbit_cbor_init_result(struct $CborResult* result) {
    result->data_ptr = 0;
    result->len = 0;
    result->error = 0;
}

void moonbit_cbor_result_free(struct $CborResult* result) {
    if (result->data_ptr != 0 && result->len > 0) {
        cbor_free((uint8_t*)(uintptr_t)result->data_ptr, (size_t)result->len);
        result->data_ptr = 0;
        result->len = 0;
    }
}

moonbit_bytes_t moonbit_cbor_result_to_bytes(struct $CborResult* result) {
    if (result->data_ptr == 0 || result->len == 0) {
        return moonbit_make_bytes(0, 0);
    }
    moonbit_bytes_t bytes = moonbit_make_bytes(result->len, 0);
    memcpy(bytes, (void*)(uintptr_t)result->data_ptr, result->len);
    return bytes;
}

// Int64 のエンコード
int32_t moonbit_cbor_encode_int(int64_t value, struct $CborResult* result) {
    struct RustCborResult rust_result = {0};
    int32_t status = cbor_encode_int(value, &rust_result);
    result->data_ptr = (int64_t)(uintptr_t)rust_result.data;
    result->len = (int32_t)rust_result.len;
    result->error = rust_result.error;
    return status;
}

// Int64 のデコード
int32_t moonbit_cbor_decode_int(moonbit_bytes_t input, int32_t input_len, int64_t* value) {
    return cbor_decode_int((const uint8_t*)input, (size_t)input_len, value);
}

// Double のエンコード
int32_t moonbit_cbor_encode_double(double value, struct $CborResult* result) {
    struct RustCborResult rust_result = {0};
    int32_t status = cbor_encode_double(value, &rust_result);
    result->data_ptr = (int64_t)(uintptr_t)rust_result.data;
    result->len = (int32_t)rust_result.len;
    result->error = rust_result.error;
    return status;
}

// Double のデコード
int32_t moonbit_cbor_decode_double(moonbit_bytes_t input, int32_t input_len, double* value) {
    return cbor_decode_double((const uint8_t*)input, (size_t)input_len, value);
}

// String のエンコード (UTF-8 bytes)
int32_t moonbit_cbor_encode_string(moonbit_bytes_t input, int32_t input_len, struct $CborResult* result) {
    struct RustCborResult rust_result = {0};
    int32_t status = cbor_encode_string((const uint8_t*)input, (size_t)input_len, &rust_result);
    result->data_ptr = (int64_t)(uintptr_t)rust_result.data;
    result->len = (int32_t)rust_result.len;
    result->error = rust_result.error;
    return status;
}

// String のデコード
int32_t moonbit_cbor_decode_string(moonbit_bytes_t input, int32_t input_len, struct $CborResult* result) {
    struct RustCborResult rust_result = {0};
    int32_t status = cbor_decode_string((const uint8_t*)input, (size_t)input_len, &rust_result);
    result->data_ptr = (int64_t)(uintptr_t)rust_result.data;
    result->len = (int32_t)rust_result.len;
    result->error = rust_result.error;
    return status;
}

// Bytes のエンコード
int32_t moonbit_cbor_encode_bytes(moonbit_bytes_t input, int32_t input_len, struct $CborResult* result) {
    struct RustCborResult rust_result = {0};
    int32_t status = cbor_encode_bytes((const uint8_t*)input, (size_t)input_len, &rust_result);
    result->data_ptr = (int64_t)(uintptr_t)rust_result.data;
    result->len = (int32_t)rust_result.len;
    result->error = rust_result.error;
    return status;
}

// Bytes のデコード
int32_t moonbit_cbor_decode_bytes(moonbit_bytes_t input, int32_t input_len, struct $CborResult* result) {
    struct RustCborResult rust_result = {0};
    int32_t status = cbor_decode_bytes((const uint8_t*)input, (size_t)input_len, &rust_result);
    result->data_ptr = (int64_t)(uintptr_t)rust_result.data;
    result->len = (int32_t)rust_result.len;
    result->error = rust_result.error;
    return status;
}

// Bool のエンコード
int32_t moonbit_cbor_encode_bool(int32_t value, struct $CborResult* result) {
    struct RustCborResult rust_result = {0};
    int32_t status = cbor_encode_bool(value, &rust_result);
    result->data_ptr = (int64_t)(uintptr_t)rust_result.data;
    result->len = (int32_t)rust_result.len;
    result->error = rust_result.error;
    return status;
}

// Bool のデコード
int32_t moonbit_cbor_decode_bool(moonbit_bytes_t input, int32_t input_len, int32_t* value) {
    return cbor_decode_bool((const uint8_t*)input, (size_t)input_len, value);
}

// Null のエンコード
int32_t moonbit_cbor_encode_null(struct $CborResult* result) {
    struct RustCborResult rust_result = {0};
    int32_t status = cbor_encode_null(&rust_result);
    result->data_ptr = (int64_t)(uintptr_t)rust_result.data;
    result->len = (int32_t)rust_result.len;
    result->error = rust_result.error;
    return status;
}

#ifdef __cplusplus
}
#endif
