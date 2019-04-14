# (WIP) WARB

WARB is WebAssembly interpreter implemented by pure Ruby.

```ruby
mod = WARB::Module.from_file("fib.wasm")

invocation = WARB::Invocation.new(mod, mod.functions.last)

invocation.execute(WARB::Value::I32.new(30))
=> #<WARB::Value i32 value:832040>
```
