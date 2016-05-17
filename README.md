# futurize

Transform js-style callbacks into [tink_core](https://github.com/haxetink/tink_core) Futures.

## Usage

```haxe
@:build(futurize.Futurize.build(":futurize"))
class AnyClass {
	public anyFunction() {
		var future = @:futurize functionWithJsStyleCallback($cb);
		future.handle(function(o) trace(o));
		
		// or without a future variable
		@:futurize functionWithJsStyleCallback($cb).handle(function(o) trace(o));
	}
	
	function functionWithJsStyleCallback(cb:String->Void) {
		cb('Error');
	}
}
```

Placeholders:
- `$cb0`: callback that returns no data, i.e. `function(err) {}`. Transforms into a `Surprise<Error, Noise>`
- `$cb` or `$cb1`: callback that returns one data, i.e. `function(err, data) {}`. Transforms into a `Surprise<Error, T>`
- `$cb2`: callback that returns two data, i.e. `function(err, data1, data2) {}`. Transforms into a `Surprise<Error, Pair<T1, T2>>`