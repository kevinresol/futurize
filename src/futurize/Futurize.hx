package futurize;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using tink.MacroApi;
using StringTools;
#end

class Futurize {
	public static macro function futurize(exprs:Array<Expr>) {
		var pos = Context.currentPos();
		var func = exprs.shift();
		
		for(i in 0...exprs.length) {
			switch exprs[i] {
				case e = macro $i{ident} if(ident.startsWith("$cb")):
					var cbNumArgs = ident == "$cb" ? 1 : Std.parseInt(ident.substr(3));
					if(cbNumArgs == null || cbNumArgs > 2) e.pos.error('[futurize] Invalid "$$cb" notation');
					exprs[i] = getCallback(cbNumArgs, macro null, e.pos);
					return macro tink.core.Future.asPromise(tink.core.Future.async(function(__futurize_cb) $func($a{exprs})));
				case _:
			}
		}
		return pos.error('[futurize] Missing $$cb placeholder');
	}
	
	#if macro
	public static function build(meta:String = ":futurize", ?custom:Expr) {
		var transformer = matchMeta.bind(_, meta, custom);
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
	
	static function matchMeta(e:Expr, meta:String, custom:Expr) {
		return switch e.expr {
			case EMeta({name: name}, expr) if(name == meta):
				var status = {
					replacedCallback: false,
					wrapped: false,
				}
				var ret = expr.transform(replaceCallback.bind(_, status, custom));
				
				if(!status.replacedCallback || !status.wrapped) 
					Context.error('[futurize] $$cb" placeholder not found, maybe something\'s wrong?', e.pos);
				
				ret;
				
			case _: e;
		}
	}
	
	static function getCallback(num:Int, custom:Expr, pos:Position) {
		return switch num {
			case 0:
				var cb = switch custom {
					case macro null: macro @:pos(pos) e != null ? tink.core.Outcome.Failure(tink.core.Error.withData('Error', e)) : tink.core.Outcome.Success(tink.core.Noise.Noise.Noise);
					default: macro @:pos(pos) $custom.cb0(e);
				}
				macro @:pos(pos) function(e) __futurize_cb($cb);
				
			case 1:
				var cb = switch custom {
					case macro null: macro @:pos(pos) e != null ? tink.core.Outcome.Failure(tink.core.Error.withData('Error', e)) : tink.core.Outcome.Success(d);
					default: macro @:pos(pos) $custom.cb1(e, d);
				}
				macro @:pos(pos) function(e, d) __futurize_cb($cb);
			
			case 2:
				var cb = switch custom {
					case macro null: macro @:pos(pos) e != null ? tink.core.Outcome.Failure(tink.core.Error.withData('Error', e)) : tink.core.Outcome.Success(new tink.core.Pair(d1, d2));
					default: macro @:pos(pos) $custom.cb2(e, d1, d2);
				}
				macro @:pos(pos) function(e, d1, d2) __futurize_cb($cb);
				
			case _:
				throw 'assert';
		}
	}
	
	static function replaceCallback(e:Expr, status, custom:Expr) {
		return switch [status.replacedCallback, status.wrapped, e] {
			
			case [true, false, _] if(e.toString().indexOf('__futurize_cb') != -1):
				status.wrapped = true;
				macro @:pos(e.pos) tink.core.Future.asPromise(tink.core.Future.async(function(__futurize_cb) $e));
			
			case [false, _, macro $i{"$cb0"}]:
				status.replacedCallback = true;
				getCallback(0, custom, e.pos);
			
			case [false, _, macro $i{"$cb" | "$cb1"}]:
				status.replacedCallback = true;
				getCallback(1, custom, e.pos);
			
			case [false, _, macro $i{"$cb2"}]:
				status.replacedCallback = true;
				getCallback(2, custom, e.pos);
			
			default: e;
		}
	}
	#end
}