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
	
	function functionWithJsStyleCallback(cb:String->String->Void) {
		try {
			// do some work...
			cb(null, 'Success');
		} catch (e:Dynamic) {
			cb('Error', null);
		}
	}
}
```

Placeholders:
- `$cb0`: callback that returns no data, i.e. `function(err) {}`. Transforms into a `Surprise<Error, Noise>`
- `$cb` or `$cb1`: callback that returns one data, i.e. `function(err, data) {}`. Transforms into a `Surprise<Error, T>`
- `$cb2`: callback that returns two data, i.e. `function(err, data1, data2) {}`. Transforms into a `Surprise<Error, Pair<T1, T2>>`
	
## Custom handlers
```haxe
@:build(futurize.Futurize.build(":futurize"), MyHandler)

class MyHandler {
	public static inline function cb0(e)
		return e == null ? Success(Noise) : Failure(e);
	
	public static inline function cb1(e, d)
		return e == null ? Success(d) : Failure(e);
	
	public static inline function cb2(e, d1, d2)
		return e == null ? Success(new Pair(d1, d2)) : Failure(e);
}
```
