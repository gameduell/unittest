/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 08/07/14
 * Time: 15:13
 */

import asyncrunner.Async;

class AsyncTest extends unittest.TestCase
{
    public function test1()
    {
        assertEquals("string", "string");

        Async.delay(function() assertAsyncFinish("test1"), 0.5);

        assertAsyncStart("test1");
    }

    public function test2()
    {
        assertAsyncStart("test2", 0.1);

        Async.delay(function() assertAsyncFinish("test2"), 0.5);

        assertShouldFail();
        ///should timeout
    }

    public function test3()
    {
        ///after 500ms, test2 timeout should happen
        assertAsyncStart("test3", 2);

        Async.delay(function() assertAsyncFinish("test3"), 1.0);
    }



}
