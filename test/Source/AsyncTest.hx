/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 08/07/14
 * Time: 15:13
 */

import haxe.Timer;
import platform.Platform;
class AsyncTest extends unittest.TestCase
{
    public function test1()
    {
        assertEquals("string", "string");

        var updatesLeft = 3;

        var updateFunction : Float -> Void = null;

        updateFunction = function(time : Float) {
            assertTrue(true);
            assertFalse(false);

            updatesLeft--;
            if(updatesLeft > 0)
            {
                assertAsyncFinish(test1);
                Platform.instance().onUpdate.remove(updateFunction);
            }
        };

        Platform.instance().onUpdate.add(updateFunction);

        assertAsyncStart(test1);
    }

    public function test2()
    {
        assertAsyncStart(test2, 0.1);

        Timer.delay(function (){assertAsyncFinish(test2);}, 1000);

        assertTrue(true);

        assertShouldFail();

        ///should timeout
    }

    public function test3()
    {
        var updatesLeft = 3;

        var updateFunction : Float -> Void = null;

        updateFunction = function(time : Float) {
            assertTrue(true);
            assertFalse(false);

            updatesLeft--;
            if(updatesLeft > 0)
            {
                assertAsyncFinish(test3);
                Platform.instance().onUpdate.remove(updateFunction);
            }
        };

        Platform.instance().onUpdate.add(updateFunction);

        assertAsyncStart(test3);
    }


}
