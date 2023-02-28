package ls.haxe;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({
    TestCore.class,
    TestExtra.class,
    TestDisconnectFuture.class
})
public class TestAll {
}
