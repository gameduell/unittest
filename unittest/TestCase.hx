/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 08/07/14
 * Time: 11:19
 */
package unittest;

import haxe.Timer;
import haxe.unit.TestCase;

import unittest.TestStatus;


class TestCase extends haxe.unit.TestCase
{
    @:allow(unittest.TestRunner)
    private var testRunner : unittest.TestRunner;

    private var currentAsyncStart : TestStatus;
    private var currentAsyncTimeout : Timer;
    private var currentAsyncFunction : Void -> Void;

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

        currentAsyncFunction = functionForAsyncToFinish;

        currentAsyncStart = cast currentTest;

        testRunner.currentTestIsAsync = true;

        currentAsyncTimeout = Timer.delay( function() {

            if(currentAsyncFunction != functionForAsyncToFinish || currentAsyncStart != currentTest)
                return; /// not the current test anymore

            currentTest.error = "Async timeout";
            currentTest.success = false;

            clearAsync();

            testRunner.endTest(currentTest);

        }, cast (timeoutInSeconds * 1000));
    }

    public function assertAsyncFinish(functionForAsyncToFinish : Void -> Void) : Void
    {
        if(currentAsyncFunction != functionForAsyncToFinish || currentAsyncStart != currentTest)
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
        currentAsyncTimeout = null;
        currentAsyncFunction = null;
    }

}