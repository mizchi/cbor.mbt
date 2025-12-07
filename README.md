# cbor.mbt

[CBOR (Concise Binary Object Representation)](https://www.rfc-editor.org/rfc/rfc8949) implementation for MoonBit.

## Features

- **Pure MoonBit implementation** - Fast, portable, works on native and wasm-gc
- **RFC 8949 compliant** - Comprehensive test suite with 22+ test cases
- **Zero dependencies** - Standalone implementation with no external dependencies
- **Well-tested** - Includes RFC 8949 example tests and roundtrip verification

## Supported Types

- Integers (signed/unsigned, Int64/UInt64)
- Floating-point numbers (64-bit Double)
- Strings (UTF-8 text strings)
- Byte arrays (byte strings)
- Booleans (true/false)
- Null values

## Usage

```moonbit
// Encoding
let encoded_int = @cbor.encode_int(42L)
let encoded_str = @cbor.encode_string("hello")
let encoded_double = @cbor.encode_double(3.14)
let encoded_bool = @cbor.encode_bool(true)
let encoded_bytes = @cbor.encode_bytes(Bytes::from_array([b'\x01', b'\x02']))
let encoded_null = @cbor.encode_null()

// Decoding
let decoded_int = @cbor.decode_int(encoded_int)!
let decoded_str = @cbor.decode_string(encoded_str)!
let decoded_double = @cbor.decode_double(encoded_double)!
let decoded_bool = @cbor.decode_bool(encoded_bool)!
let decoded_bytes = @cbor.decode_bytes(encoded_bytes)!
```

## Installation

Add to your `moon.mod.json`:
```json
{
  "deps": {
    "mizchi/cbor": "0.1.0"
  }
}
```

## Testing

The library includes comprehensive tests covering:

- **RFC 8949 Examples** - Validates encoding against official specification examples
- **Roundtrip Tests** - Ensures encode/decode operations are reversible
- **Edge Cases** - Tests boundary values and special cases

```bash
# Run all tests
moon test

# Total: 22 tests covering all supported types
```

### Test Coverage

- Integer encoding (positive, negative, various sizes)
- String encoding (ASCII, Unicode, emoji)
- Byte array encoding (empty, various sizes)
- Boolean and null values
- Double precision floats (including infinity)
- Boundary value testing (format transitions at 24, 256, 65536)

## Examples

See `examples/` directory for usage examples:

```bash
moon run examples
```

## Project Structure

```
cbor.mbt              # Main CBOR implementation
cbor_test.mbt         # Comprehensive test suite (22+ tests)
cbor_bench.mbt        # Performance benchmarks
examples/             # Usage examples
  └── main.mbt       # Example usage
cbor_rust/           # Rust reference implementation (for comparison)
  └── src/lib.rs     # ciborium-based implementation
```

## License

MIT License

## References

- [RFC 8949 - CBOR Specification](https://www.rfc-editor.org/rfc/rfc8949)
- [ciborium - Rust CBOR library](https://crates.io/crates/ciborium)
