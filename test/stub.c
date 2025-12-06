// Test oracle: Manual CBOR implementation in C
// Based on RFC 8949 - minimal implementation for testing

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <moonbit.h>

#ifdef __cplusplus
extern "C" {
#endif

// Helper: write CBOR header (major type + additional info)
static size_t write_cbor_header(uint8_t* buf, uint8_t major, uint64_t value) {
    major <<= 5;
    if (value < 24) {
        buf[0] = major | (uint8_t)value;
        return 1;
    } else if (value < 256) {
        buf[0] = major | 24;
        buf[1] = (uint8_t)value;
        return 2;
    } else if (value < 65536) {
        buf[0] = major | 25;
        buf[1] = (uint8_t)(value >> 8);
        buf[2] = (uint8_t)value;
        return 3;
    } else if (value < 4294967296ULL) {
        buf[0] = major | 26;
        buf[1] = (uint8_t)(value >> 24);
        buf[2] = (uint8_t)(value >> 16);
        buf[3] = (uint8_t)(value >> 8);
        buf[4] = (uint8_t)value;
        return 5;
    } else {
        buf[0] = major | 27;
        buf[1] = (uint8_t)(value >> 56);
        buf[2] = (uint8_t)(value >> 48);
        buf[3] = (uint8_t)(value >> 40);
        buf[4] = (uint8_t)(value >> 32);
        buf[5] = (uint8_t)(value >> 24);
        buf[6] = (uint8_t)(value >> 16);
        buf[7] = (uint8_t)(value >> 8);
        buf[8] = (uint8_t)value;
        return 9;
    }
}

// Encode int64 to CBOR
moonbit_bytes_t oracle_encode_int(int64_t value) {
    uint8_t buf[9];
    size_t len;

    if (value >= 0) {
        len = write_cbor_header(buf, 0, (uint64_t)value);
    } else {
        len = write_cbor_header(buf, 1, (uint64_t)(-1 - value));
    }

    moonbit_bytes_t result = moonbit_make_bytes(len, 0);
    memcpy(result, buf, len);
    return result;
}

// Encode double (64-bit float) to CBOR
moonbit_bytes_t oracle_encode_double(double value) {
    uint8_t buf[9];
    buf[0] = 0xfb;  // Major type 7, additional info 27 (64-bit float)

    uint64_t bits;
    memcpy(&bits, &value, sizeof(bits));

    buf[1] = (uint8_t)(bits >> 56);
    buf[2] = (uint8_t)(bits >> 48);
    buf[3] = (uint8_t)(bits >> 40);
    buf[4] = (uint8_t)(bits >> 32);
    buf[5] = (uint8_t)(bits >> 24);
    buf[6] = (uint8_t)(bits >> 16);
    buf[7] = (uint8_t)(bits >> 8);
    buf[8] = (uint8_t)bits;

    moonbit_bytes_t result = moonbit_make_bytes(9, 0);
    memcpy(result, buf, 9);
    return result;
}

// Encode string (UTF-8 text) to CBOR
moonbit_bytes_t oracle_encode_string(moonbit_bytes_t input, int32_t input_len) {
    uint8_t header[9];
    size_t header_len = write_cbor_header(header, 3, (uint64_t)input_len);

    size_t total_len = header_len + input_len;
    moonbit_bytes_t result = moonbit_make_bytes(total_len, 0);
    memcpy(result, header, header_len);
    memcpy(result + header_len, input, input_len);
    return result;
}

// Encode bytes to CBOR
moonbit_bytes_t oracle_encode_bytes(moonbit_bytes_t input, int32_t input_len) {
    uint8_t header[9];
    size_t header_len = write_cbor_header(header, 2, (uint64_t)input_len);

    size_t total_len = header_len + input_len;
    moonbit_bytes_t result = moonbit_make_bytes(total_len, 0);
    memcpy(result, header, header_len);
    memcpy(result + header_len, input, input_len);
    return result;
}

// Encode bool to CBOR
moonbit_bytes_t oracle_encode_bool(int32_t value) {
    moonbit_bytes_t result = moonbit_make_bytes(1, 0);
    result[0] = value ? 0xf5 : 0xf4;  // true = 0xf5, false = 0xf4
    return result;
}

// Encode null to CBOR
moonbit_bytes_t oracle_encode_null(void) {
    moonbit_bytes_t result = moonbit_make_bytes(1, 0);
    result[0] = 0xf6;  // null
    return result;
}

#ifdef __cplusplus
}
#endif
