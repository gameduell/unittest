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

    public function new() : Void
    {
        currentAsyncStart = null;

        super();
    }

    public function assertAsyncStart(timeoutInSeconds : Float = 1.0) : Void
    {
        if(currentAsyncStart != null)
        {
            throw "Can only have one async assert at one time";
        }

        currentAsyncStart = cast currentTest;

        testRunner.currentTestIsAsync = true;

        currentAsyncTimeout = Timer.delay( function() {

            if(currentTest != currentAsyncStart)
                return; /// not the current test anymore

            currentTest.error = "Async timeout";
            currentTest.success = false;

            clearAsync();

            testRunner.endTest(currentTest);

        }, cast (timeoutInSeconds * 1000));
    }

    public function assertAsyncFinish() : Void
    {
        if(currentAsyncStart != currentTest)
        {
            return; /// timeout happened before
        }

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
    }

}