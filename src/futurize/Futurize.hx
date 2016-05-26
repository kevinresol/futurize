package futurize;

import haxe.macro.Expr;
import haxe.macro.Context;
using tink.MacroApi;

class Futurize {
	public static function build(meta:String = ":futurize", ?callback:Expr) {
		var transformer = matchMeta.bind(_, meta, callback);
		return [for(field in Context.getBuildFields()) {
			switch field.kind {
				case FFun(func):
					func.expr = func.expr.transform(transformer);
				case FVar(t, e):
					field.kind = FVar(t, e == null ? null : e.transform(transformer));
				case FProp(get, set, t, e):
					field.kind = FProp(get, set, t, e == null ? null : e.transform(transformer));
			}
			field;
		}];
	}
	
	static function matchMeta(e:Expr, meta:String, callback:Expr) {
		return switch e.expr {
			case EMeta({name: name}, expr) if(name == meta):
				var status = {
					replacedCallback: false,
					wrapped: false,
				}
				var ret = expr.transform(replaceCallback.bind(_, status, callback));
				
				if(!status.replacedCallback || !status.wrapped) 
					Context.error("\"$cb\" placeholder not found, maybe something's wrong?", e.pos);
				
				ret;
				
			case _: e;
		}
	}
	
	static function replaceCallback(e:Expr, status, callback:Expr) {
		return switch [status.replacedCallback, status.wrapped, e] {
			
			case [true, false, _] if(e.toString().indexOf('__futurize_cb') != -1):
				status.wrapped = true;
				macro @:pos(e.pos) tink.core.Future.async(function(__futurize_cb) $e);
			
			case [false, _, macro $i{"$cb0"}]:
				status.replacedCallback = true;
				var cb = switch callback {
					case macro null: macro e != null ? tink.core.Outcome.Failure(tink.core.Error.withData('Error', e)) : tink.core.Outcome.Success(tink.core.Noise.Noise.Noise);
					default: macro $callback.cb0(e);
				}
				macro @:pos(e.pos) function(e) __futurize_cb($cb);
			
			case [false, _, macro $i{"$cb" | "$cb1"}]:
				status.replacedCallback = true;
				var cb = switch callback {
					case macro null: macro e != null ? tink.core.Outcome.Failure(tink.core.Error.withData('Error', e)) : tink.core.Outcome.Success(d);
					default: macro $callback.cb1(e, d);
				}
				macro @:pos(e.pos) function(e, d) __futurize_cb($cb);
			
			case [false, _, macro $i{"$cb2"}]:
				status.replacedCallback = true;
				var cb = switch callback {
					case macro null: macro e != null ? tink.core.Outcome.Failure(tink.core.Error.withData('Error', e)) : tink.core.Outcome.Success(new tink.core.Pair(d1, d2));
					default: macro $callback.cb2(e, d1, d2);
				}
				macro @:pos(e.pos) function(e, d1, d2) __futurize_cb($cb);
			
			default: e;
		}
	}
}