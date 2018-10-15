package;

import tink.unit.Assert.assert;
import haxe.Timer;

using tink.CoreApi;

@:await
@:build(futurize.Futurize.build(":futurize"))
class TestAwait {
	public function new() {}
		
	@:async public function withIntermediateFutureVariable() {
		try {
			var o = @:await @:futurize a().test0($cb0);
		} catch(e:Error) {
			return assert(e.message == 'Error');
		}
		
	}
			
	@:async public function withoutIntermediateFutureVariable() {
		try {
			var o = @:await @:futurize a().test0($cb0);
		} catch(e:Error) {
			return assert(e.message == 'Error');
		}
	}
			
	@:async public function multipleMetas() {
		try {
			var o = @:await @:futurize @other a().test0($cb0);
		} catch(e:Error) {
			return assert(e.message == 'Error');
		}
	}
			
	// public function map() {
	// 	var future = @:futurize @other a().test0($cb0) >>
	// 		function(_) return @:futurize test0($cb0);
					
	// 	return future.map(function(o) return assert(true));
	// }
			
	@:async public function cb() {
		try {
			var o = @:await @:futurize a().test1($cb);
		} catch(e:Error) {
			return assert(e.message == 'Error');
		}
	}
			
	@:async public function cb1() {
		try {
			var o = @:await @:futurize a().test1($cb1);
		} catch(e:Error) {
			return assert(e.message == 'Error');
		}
	}
			
	@:async public function cb2() {
		try {
			var o = @:await @:futurize a().test2($cb2);
		} catch(e:Error) {
			return assert(e.message == 'Error');
		}
	}
	
	@:async public function withParamsBefore() {		
		try {
			var o = @:await @:futurize withOtherParamsBefore(100, $cb0);
		} catch(e:Error) {
			return assert(e.message == 'Error');
		}
	}
			
	@:async public function withParamsAfter() {		
		try {
			var o = @:await @:futurize withOtherParamsAfter($cb0, 100);
		} catch(e:Error) {
			return assert(e.message == 'Error');
		}
	}
	
	function a()
		return {
			test0: test0,
			test1: test1,
			test2: test2,
		};
	
	function test0(cb:String->Void) {
		Timer.delay(cb.bind("Error"), 100);
	}
	function test1(cb:String->String->Void) {
		Timer.delay(cb.bind("Error", null), 100);
	}
	function test2(cb:String->String->String->Void) {
		Timer.delay(cb.bind("Error", null, null), 100);
	}
	
	function withOtherParamsAfter(cb:String->Void, interval:Int):Void {
		Timer.delay(cb.bind("Error"), interval);
	}
	function withOtherParamsBefore(interval:Int, cb:String->Void):Void {
		Timer.delay(cb.bind("Error"), interval);
	}
}