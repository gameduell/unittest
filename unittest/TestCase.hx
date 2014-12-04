/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 08/07/14
 * Time: 11:19
 */
package unittest;

import haxe.unit.TestCase;
import haxe.PosInfos;

import unittest.TestStatus;

import runloop.RunLoop;

class TestCase extends haxe.unit.TestCase
{
    @:allow(unittest.TestRunner)
    private var testRunner : unittest.TestRunner;

    private var currentAsyncStart : TestStatus;

    @:allow(unittest.TestRunner)
    private var currentFunction : Void -> Void;

    public function new() : Void
    {
        currentAsyncStart = null;

        super();
    }

    public function assertAsyncStart(functionForAsyncToFinish : Void -> Void, timeoutInSeconds : Float = 1.0) : Void
    {
        if(currentAsyncStart != null)
        {
            throw "Can only have one async assert at one time";
        }

        if (currentFunction != functionForAsyncToFinish)
        {
            throw "assertAsyncStart function and current function mismatch";
        }

        currentAsyncStart = cast currentTest;

        testRunner.currentTestIsAsync = true;

        RunLoop.getMainLoop().delay(function() {

            if(currentFunction != functionForAsyncToFinish || currentAsyncStart != currentTest || testRunner == null)
                return; /// not the current test anymore

            currentTest.error = "Async timeout";
            currentTest.success = false;

            clearAsync();
            testRunner.endTest(currentTest);

        }, timeoutInSeconds);
    }

    public function assertAsyncFinish(functionForAsyncToFinish : Void -> Void) : Void
    {
        if(currentFunction != functionForAsyncToFinish || currentAsyncStart != currentTest)
        {
            return; /// timeout happened before
        }

        currentTest.done = true;

        clearAsync();

        testRunner.endTest();
    }

    public function assertShouldFail() : Void
    {
        testRunner.currentTestShouldFail = true;
    }

    public function clearAsync() : Void
    {
        currentAsyncStart = null;
    }

    function assertAsyncTrue(functionForAsyncToFinish : Void -> Void, b:Bool, ?c : PosInfos ): Void 
    {
        if(currentFunction != functionForAsyncToFinish || currentAsyncStart != currentTest)
        {
            return; /// not this test anymore
        }
        super.assertTrue(b, c);
    }

    function assertAsyncFalse(functionForAsyncToFinish : Void -> Void, b:Bool, ?c : PosInfos ) : Void 
    {
        if(currentFunction != functionForAsyncToFinish || currentAsyncStart != currentTest)
        {
            return; /// not this test anymore
        }
        super.assertFalse(b, c);
    }

    function assertAsyncEquals<T>(functionForAsyncToFinish: Void -> Void, expected: T , actual: T,  ?c : PosInfos ) : Void  
    {
        if(currentFunction != functionForAsyncToFinish || currentAsyncStart != currentTest)
        {
            return; /// not this test anymore
        }

        super.assertEquals(expected, actual, c);
    }

}