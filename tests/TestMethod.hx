package;

import futurize.Futurize.futurize;
import tink.unit.Assert.assert;
using tink.CoreApi;

class TestMethod extends Base {
	public function withIntermediateFutureVariable() {
		var future = futurize(a().test0, $cb0);
		return future.map(function(o) return assert(!o.isSuccess()));
		
	}
			
	public function withoutIntermediateFutureVariable() {
		return futurize(a().test0, $cb0)
			.map(function(o) return assert(!o.isSuccess()));
	}
			
	public function withMeta() {
		return futurize(@other a().test0, $cb0)
			.map(function(o) return assert(!o.isSuccess()));
	}
	
	public function cb() {
		var future = futurize(a().test1, $cb);
		return future.map(function(o) return assert(!o.isSuccess()));
	}
			
	public function cb1() {
		var future = futurize(a().test1, $cb1);
		return future.map(function(o) return assert(!o.isSuccess()));
	}
			
	public function cb2() {
		var future = futurize(a().test2, $cb2);
		return future.map(function(o) return assert(!o.isSuccess()));
	}
	
	public function withParamsBefore() {		
		var future = futurize(withOtherParamsBefore, 100,  $cb0);
		return future.map(function(o) return assert(!o.isSuccess()));
	}
			
	public function withParamsAfter() {		
		var future = futurize(withOtherParamsAfter, $cb0, 100);
		return future.map(function(o) return assert(!o.isSuccess()));
	}
}