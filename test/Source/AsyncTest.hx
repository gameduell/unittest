/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 08/07/14
 * Time: 15:13
 */

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
                assertAsyncFinish();
                Platform.instance().onUpdate.remove(updateFunction);
            }
        };

        Platform.instance().onUpdate.add(updateFunction);

        assertAsyncStart();
    }



    public function testStartAnotherOneBeforeTimeout1()
    {
        assertAsyncStart(0.1);

        assertShouldFail();

        ///should timeout after the other one is started
    }



    public function testStartAnotherOneBeforeTimeout2()
    {
        var updatesLeft = 3;

        var updateFunction : Float -> Void = null;

        updateFunction = function(time : Float) {
            assertTrue(true);
            assertFalse(false);

            updatesLeft--;
            if(updatesLeft > 0)
            {
                assertAsyncFinish();
                Platform.instance().onUpdate.remove(updateFunction);
            }
        };

        Platform.instance().onUpdate.add(updateFunction);

        assertAsyncStart();
    }


}
