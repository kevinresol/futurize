package;

import tink.unit.*;
import tink.testrunner.*;

class RunTests {
	static function main() {
		Runner.run(TestBatch.make([
			new TestMeta(),
			new TestMethod(),
			new TestAwait(),
			new TestCustom(),
		]));
	}
}