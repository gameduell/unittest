/*
 * Created by IntelliJ IDEA.
 * User: jxav
 * Date: 29/04/15
 * Time: 17:03
 */

import asyncrunner.Async;

class FunctionalTest extends unittest.TestCase
{
    private var counter: Int;
    private var flag: Bool;

    public function new()
    {
        super();

        counter = 0;
        flag = true;
    }

    @try(4)
    public function testRandom()
    {
        assertTrue(Math.random() > 0.3);
    }

    @try(5)
    public function testFourFailsOneSuccess()
    {
        counter++;

        assertEquals(5, counter);
    }

    @try(2)
    public function testAsyncFailsFirstTimeWorksSecond()
    {
        Async.delay(function(): Void
        {
            flag = !flag;

            // will work the 2nd time
            assertTrue(flag);

            assertAsyncFinish("testAsyncFailsFirstTimeWorksSecond");
        }, 2.0);

        assertAsyncStart("testAsyncFailsFirstTimeWorksSecond", 3.0);
    }

    @try(0)
    public function testWithZeroTries()
    {
        // should always execute once
        assertTrue(true);
    }

    @try(-1)
    public function testWithNegativeTries()
    {
        // surprise surprise, should always execute once
        assertTrue(true);
    }

    public function testWithoutTry()
    {
        assertTrue(true);
    }
}
