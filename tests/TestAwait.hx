package;

import tink.unit.Assert.assert;
using tink.CoreApi;

@:await
@:build(futurize.Futurize.build(":futurize"))
class TestAwait extends Base {
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
}