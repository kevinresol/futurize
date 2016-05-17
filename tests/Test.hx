package;

import haxe.Timer;
import buddy.*;
using buddy.Should;
using tink.CoreApi;

@:build(futurize.Futurize.build(":futurize"))
class Test extends BuddySuite {
	public function new() {
		describe("", {
			it("With intermediate future variable", function(done) {
				var future = @:futurize a().test0($cb0);
				future.handle(function(o) switch o {
					case Failure(err): done();
					default: fail('something wrong');
				});
			});
			
			it("Without intermediate future variable", function(done) {
				@:futurize a().test0($cb0).handle(function(o) switch o {
					case Failure(err): done();
					default: fail('something wrong');
				});
			});
			
			it("Test multiple metas", function(done) {
				@:futurize @other a().test0($cb0).handle(function(o) switch o {
					case Failure(err): done();
					default: fail('something wrong');
				});
			});
			
			it("Test map", function(done) {
				var future = @:futurize @other a().test0($cb0) >>
					function(_) return @:futurize test0($cb0);
					
				future.handle(function(o) switch o {
					case Failure(err): done();
					default: fail('something wrong');
				});
			});
			
			it("Test cb", function(done) {
				var future = @:futurize a().test1($cb);
				future.handle(function(o) switch o {
					case Failure(err): done();
					default: fail('something wrong');
				});
			});
			
			it("Test cb1", function(done) {
				var future = @:futurize a().test1($cb1);
				future.handle(function(o) switch o {
					case Failure(err): done();
					default: fail('something wrong');
				});
			});
			
			it("Test cb2", function(done) {
				var future = @:futurize a().test2($cb2);
				future.handle(function(o) switch o {
					case Failure(err): done();
					default: fail('something wrong');
				});
			});
			
			it("Test functions with other params before", function(done) {
				var future = @:futurize withOtherParamsBefore(100, $cb0);
				future.handle(function(o) switch o {
					case Failure(err): done();
					default: fail('something wrong');
				});
			});
			
			it("Test functions with other params after", function(done) {
				var future = @:futurize withOtherParamsAfter($cb0, 100);
				future.handle(function(o) switch o {
					case Failure(err): done();
					default: fail('something wrong');
				});
			});
		});
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