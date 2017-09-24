package futurize;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;
import tink.SyntaxHub;

using tink.MacroApi;

class Futurize {
	public static function use() {
		function appliesTo(m:MetaAccess) return m.has(':futurize');
		SyntaxHub.classLevel.before(
			function (_) return true,
			function (c: ClassBuilder) {
				if(c.target.name == 'CampaignResponse_Impl_') trace(c.target.meta.has(':futurize'));
				if (c.target.isInterface && !appliesTo(c.target.meta))
					return false;
				
				if (!appliesTo(c.target.meta)) {
					for (i in c.target.interfaces)
						if (appliesTo(i.t.get().meta)) {
							applyTo(c);
							return true;
						}
					var s = c.target.superClass;
					while(s != null) {
						var sc = s.t.get();
						if(appliesTo(sc.meta)) {
							applyTo(c);
							return true;
						}
						s = sc.superClass;
					}
					return false;
				}
				else {
					applyTo(c);
					return true;
				}
			}
		);
	}
	
	static function applyTo(builder:ClassBuilder) {
		var transformer = matchMeta.bind(_, [
			':futurize' => macro null,
			':promisify' => macro null,
		],[
			':futurize' => function(e) return macro @:pos(e.pos) tink.core.Future.async($e),
			':promisify' => function(e) return macro @:pos(e.pos) tink.core.Future.asPromise(tink.core.Future.async($e)),
		]);
		return [for(field in builder) {
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
	
	static function matchMeta(e:Expr, callback:Map<String, Expr>, wrap:Map<String, Expr->Expr>) {
		return switch e.expr {
			case EMeta({name: name}, expr) if(callback.exists(name) && wrap.exists(name)):
				var status = {
					replacedCallback: false,
					wrapped: false,
				}
				
				var ret = expr.transform(replaceCallback.bind(_, status, callback.get(name), wrap.get(name)));
				
				if(!status.replacedCallback || !status.wrapped) 
					Context.error("Futurize: \"$cb\" placeholder not found, maybe something's wrong?", e.pos);
				
				// trace(ret.toString());
				ret;
				
			case _: e;
		}
	}
	
	static function replaceCallback(e:Expr, status, callback:Expr, wrap:Expr->Expr) {
		return switch [status.replacedCallback, status.wrapped, e] {
			
			case [true, false, _] if(e.toString().indexOf('__futurize_cb') != -1):
				status.wrapped = true;
				wrap(macro @:pos(e.pos) function(__futurize_cb) $e);
			
			case [false, _, macro $i{"$cb0"}]:
				status.replacedCallback = true;
				var cb = switch callback {
					case macro null: macro @:pos(e.pos) e != null ? tink.core.Outcome.Failure(tink.core.Error.withData('Error', e)) : tink.core.Outcome.Success(tink.core.Noise.Noise.Noise);
					default: macro @:pos(e.pos) $callback.cb0(e);
				}
				macro @:pos(e.pos) function(e) __futurize_cb($cb);
			
			case [false, _, macro $i{"$cb" | "$cb1"}]:
				status.replacedCallback = true;
				var cb = switch callback {
					case macro null: macro @:pos(e.pos) e != null ? tink.core.Outcome.Failure(tink.core.Error.withData('Error', e)) : tink.core.Outcome.Success(d);
					default: macro @:pos(e.pos) $callback.cb1(e, d);
				}
				macro @:pos(e.pos) function(e, d) __futurize_cb($cb);
			
			case [false, _, macro $i{"$cb2"}]:
				status.replacedCallback = true;
				var cb = switch callback {
					case macro null: macro @:pos(e.pos) e != null ? tink.core.Outcome.Failure(tink.core.Error.withData('Error', e)) : tink.core.Outcome.Success(new tink.core.Pair(d1, d2));
					default: macro @:pos(e.pos) $callback.cb2(e, d1, d2);
				}
				macro @:pos(e.pos) function(e, d1, d2) __futurize_cb($cb);
			
			default: e;
		}
	}
}