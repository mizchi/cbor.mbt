use criterion::{black_box, criterion_group, criterion_main, Criterion};
use std::io::Cursor;

fn encode_int(value: i64) -> Vec<u8> {
    let mut buffer = Vec::new();
    ciborium::into_writer(&value, &mut buffer).unwrap();
    buffer
}

fn decode_int(data: &[u8]) -> i64 {
    let cursor = Cursor::new(data);
    ciborium::from_reader(cursor).unwrap()
}

fn encode_double(value: f64) -> Vec<u8> {
    let mut buffer = Vec::new();
    ciborium::into_writer(&value, &mut buffer).unwrap();
    buffer
}

fn decode_double(data: &[u8]) -> f64 {
    let cursor = Cursor::new(data);
    ciborium::from_reader(cursor).unwrap()
}

fn encode_string(value: &str) -> Vec<u8> {
    let mut buffer = Vec::new();
    ciborium::into_writer(&value, &mut buffer).unwrap();
    buffer
}

fn decode_string(data: &[u8]) -> String {
    let cursor = Cursor::new(data);
    ciborium::from_reader(cursor).unwrap()
}

fn encode_bytes(value: &[u8]) -> Vec<u8> {
    let mut buffer = Vec::new();
    let bytes = ciborium::value::Value::Bytes(value.to_vec());
    ciborium::into_writer(&bytes, &mut buffer).unwrap();
    buffer
}

fn decode_bytes(data: &[u8]) -> Vec<u8> {
    let cursor = Cursor::new(data);
    let value: ciborium::value::Value = ciborium::from_reader(cursor).unwrap();
    match value {
        ciborium::value::Value::Bytes(b) => b,
        _ => panic!("Expected bytes"),
    }
}

fn encode_bool(value: bool) -> Vec<u8> {
    let mut buffer = Vec::new();
    ciborium::into_writer(&value, &mut buffer).unwrap();
    buffer
}

fn decode_bool(data: &[u8]) -> bool {
    let cursor = Cursor::new(data);
    ciborium::from_reader(cursor).unwrap()
}

fn criterion_benchmark(c: &mut Criterion) {
    // Int benchmarks
    c.bench_function("encode_int", |b| {
        b.iter(|| encode_int(black_box(12345678901234i64)))
    });

    let encoded_int = encode_int(12345678901234i64);
    c.bench_function("decode_int", |b| {
        b.iter(|| decode_int(black_box(&encoded_int)))
    });

    // Double benchmarks
    c.bench_function("encode_double", |b| {
        b.iter(|| encode_double(black_box(3.141592653589793)))
    });

    let encoded_double = encode_double(3.141592653589793);
    c.bench_function("decode_double", |b| {
        b.iter(|| decode_double(black_box(&encoded_double)))
    });

    // String benchmarks
    c.bench_function("encode_string", |b| {
        b.iter(|| encode_string(black_box("Hello, CBOR! こんにちは")))
    });

    let encoded_string = encode_string("Hello, CBOR! こんにちは");
    c.bench_function("decode_string", |b| {
        b.iter(|| decode_string(black_box(&encoded_string)))
    });

    // Bytes benchmarks
    let test_bytes: [u8; 5] = [0x01, 0x02, 0x03, 0x04, 0x05];
    c.bench_function("encode_bytes", |b| {
        b.iter(|| encode_bytes(black_box(&test_bytes)))
    });

    let encoded_bytes = encode_bytes(&test_bytes);
    c.bench_function("decode_bytes", |b| {
        b.iter(|| decode_bytes(black_box(&encoded_bytes)))
    });

    // Bool benchmarks
    c.bench_function("encode_bool", |b| {
        b.iter(|| encode_bool(black_box(true)))
    });

    let encoded_bool = encode_bool(true);
    c.bench_function("decode_bool", |b| {
        b.iter(|| decode_bool(black_box(&encoded_bool)))
    });
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
