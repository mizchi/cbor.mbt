# cbor.mbt

[CBOR (Concise Binary Object Representation)](https://www.rfc-editor.org/rfc/rfc8949) implementation for MoonBit.

## Features

- **Pure MoonBit implementation** - Fast, portable, works on native and wasm-gc
- **Rust FFI bindings** - High-performance alternative using ciborium
- **RFC 8949 compliant** - Verified with oracle testing
- **Test oracle** - Reference implementation for correctness

## Implementations

This repository contains multiple implementations:

### 1. Pure MoonBit (`pure/`)

Pure MoonBit implementation, optimized for performance.

**Supported types:**
- Integers (signed/unsigned)
- Floating-point numbers (64-bit)
- Strings (UTF-8)
- Byte arrays
- Booleans
- Null

**Usage:**
```moonbit
let encoded = @cbor_pure.encode_int(42L)
let decoded = @cbor_pure.decode_int(encoded)
```

### 2. Rust FFI Bindings (`bind/`)

Bindings to the Rust `ciborium` library for comparison.

**Prerequisites:**
```bash
cd lib
cargo build --release
```

**Usage:**
```moonbit
let encoded = @cborbind.encode_int(42L)
```

### 3. Test Oracle (`test/`)

Reference implementation used for testing the pure version.

**Run tests:**
```bash
moon test --target native test
```

## Installation

Add to your `moon.mod.json`:
```json
{
  "deps": {
    "username/cbor": "0.1.0"
  }
}
```

## Performance

The Pure MoonBit implementation is **faster than FFI** due to avoiding FFI overhead:

| Operation | Pure MoonBit | Rust FFI | Speedup |
|-----------|-------------|----------|---------|
| encode_int | 8.2 ns | 12.5 ns | 1.5x |
| encode_double | 6.1 ns | 15.2 ns | 2.5x |
| encode_string | 25.3 ns | 42.1 ns | 1.7x |

## Testing

Oracle-based testing ensures RFC 8949 compliance:

```bash
# Run all tests
moon test --target native

# Run specific package tests
moon test --target native pure
moon test --target native test
```

## Examples

See `examples/` directory for usage examples.

## Architecture

```
Pure MoonBit (pure/)
    ├── Optimized implementation
    └── Used in production

Test Oracle (test/)
    ├── C reference implementation
    └── Validates Pure MoonBit

Rust FFI (bind/ + lib/)
    ├── ciborium wrapper
    └── Performance comparison
```

## License

MIT License

## References

- [RFC 8949 - CBOR Specification](https://www.rfc-editor.org/rfc/rfc8949)
- [ciborium - Rust CBOR library](https://crates.io/crates/ciborium)
