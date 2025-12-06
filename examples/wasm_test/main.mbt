///|
fn main {
  println("=== CBOR WASM Loading Test ===")
  if not(@wasmtime_static.load()) {
    println("Failed to load wasmtime")
    return
  }
  let config = match @wasmtime_static.Config::new() {
    Some(c) => c
    None => {
      println("Failed to create config")
      return
    }
  }

  // wasm-gc に必要な機能を有効化
  let _ = config
    .set_wasm_gc(true)
    .set_wasm_function_references(true)
    .set_wasm_reference_types(true)
    .set_wasm_tail_call(true)
  let engine = match config.build() {
    Some(e) => e
    None => {
      println("Failed to create engine")
      return
    }
  }
  println("Created engine with GC support")

  // ファイル読み込み
  let wasm_path = "target/wasm-gc/release/build/cbor_pure/cbor_pure.wasm"
  let wasm_bytes = match @wasmtime_static.read_file(wasm_path) {
    Ok(bytes) => bytes
    Err(e) => {
      println("Failed to read file: \{e}")
      return
    }
  }
  println("Read WASM: \{wasm_bytes.length()} bytes")

  // モジュールをコンパイル
  let mod_ = match @wasmtime_static.Module::new(engine, wasm_bytes) {
    Ok(m) => m
    Err(e) => {
      println("Failed to compile: \{e}")
      return
    }
  }
  println("Compiled module")

  // Store を作成
  let store = match @wasmtime_static.Store::new(engine) {
    Some(s) => s
    None => {
      println("Failed to create store")
      return
    }
  }
  let ctx = match store.context() {
    Some(c) => c
    None => {
      println("Failed to get context")
      return
    }
  }

  // Linker を作成して spectest を定義
  let linker = match @wasmtime_static.Linker::new(engine) {
    Some(l) => l
    None => {
      println("Failed to create linker")
      return
    }
  }
  let _ = linker.define_spectest()

  // インスタンス化
  println("Instantiating...")
  let instance = match linker.instantiate(ctx, mod_) {
    Ok(inst) => {
      println("Instantiated OK")
      inst
    }
    Err(e) => {
      println("Failed to instantiate: \{e}")
      return
    }
  }

  // _start 関数を呼び出し
  println("")
  println("--- Running CBOR Pure Demo ---")
  match instance.get_func(ctx, "_start") {
    Some(start_func) =>
      match @wasmtime_static.call_void_void(start_func, ctx) {
        Ok(_) => println("--- Demo Complete ---")
        Err(e) => println("Error: \{e}")
      }
    None => println("_start function not found")
  }
}
