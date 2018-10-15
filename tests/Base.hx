package;

import haxe.Timer;

class Base {
	public function new() {}
	
	function a()
		return {
			test0: test0,
			test1: test1,
			test2: test2,
		};
	
	function test0(cb:String->Void) {
		Timer.delay(cb.bind("Error"), 10);
	}
	function test1(cb:String->String->Void) {
		Timer.delay(cb.bind("Error", null), 10);
	}
	function test2(cb:String->String->String->Void) {
		Timer.delay(cb.bind("Error", null, null), 10);
	}
	
	function withOtherParamsAfter(cb:String->Void, interval:Int):Void {
		Timer.delay(cb.bind("Error"), interval);
	}
	function withOtherParamsBefore(interval:Int, cb:String->Void):Void {
		Timer.delay(cb.bind("Error"), interval);
	}
}