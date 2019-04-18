# (WIP) WARB

WARB is WebAssembly interpreter implemented by pure Ruby.

```ruby
mod = WARB::Module.from_file("fib.wasm")

mod.exported_function_names
=> ["main", "fib"]

mod.exported_function("fib").invoke(WARB::Value::I32.new(30))
=> [#<WARB::Value::I32:0x00007f9f1003a028 @value=832040>]
```

## TODO

 * Implementing numeric instructions
