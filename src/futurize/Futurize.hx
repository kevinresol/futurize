package futurize;

import haxe.macro.Expr;
import haxe.macro.Context;
using tink.MacroApi;

class Futurize {
	public static function build(meta:String) {
		
		return [for(field in Context.getBuildFields()) {
			switch field.kind {
				case FFun(func):
					func.expr = func.expr.transform(matchMeta.bind(_, meta));
				default:
			}
			field;
		}];
	}
	
	static function matchMeta(e:Expr, meta:String) {
		return switch e.expr {
			case EMeta({name: name}, expr) if(name == meta):
				var status = {
					replacedCallback: false,
					wrapped: false,
				}
				expr.transform(replaceCallback.bind(_, status));
			case _: e;
		}
	}
	
	static function replaceCallback(e:Expr, status) {
		
		return if(status.replacedCallback && !status.wrapped) {
			status.wrapped = true;
			macro tink.core.Future.async(function(cb) $e);
		} else switch e {
			
			case macro $i{"$cb0"}:
				status.replacedCallback = true;
				return macro function(e) cb(e != null ? tink.core.Outcome.Failure(tink.core.Error.withData('Error', e)) : tink.core.Outcome.Success(tink.core.Noise.Noise));
			case macro $i{"$cb" | "$cb1"}:
				status.replacedCallback = true;
				return macro function(e, d) cb(e != null ? tink.core.Outcome.Failure(tink.core.Error.withData('Error', e)) : tink.core.Outcome.Success(d));
			case macro $i{"$cb2"}:
				status.replacedCallback = true;
				return macro function(e, d1, d2) cb(e != null ? tink.core.Outcome.Failure(tink.core.Error.withData('Error', e)) : tink.core.Outcome.Success(new tink.core.Pair(d1, d2)));
			case e: e;
		}
	}
}