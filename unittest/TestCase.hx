/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package unittest;

import haxe.unit.TestCase;
import haxe.PosInfos;

import unittest.TestStatus;

import runloop.RunLoop;

import org.hamcrest.Matchers;
import org.hamcrest.Matcher;

class TestCase extends haxe.unit.TestCase
{
    @:allow(unittest.TestRunner)
    private var testRunner: unittest.TestRunner;

    @:allow(unittest.TestRunner)
    private var currentAsyncStart: TestStatus;

    @:allow(unittest.TestRunner)
    private var currentFunctionName: String;

    public function new(): Void
    {
        currentAsyncStart = null;

        super();
    }

    public function assertAsyncStart(functionNameForAsyncToFinish: String, timeoutInSeconds : Float = 1.0): Void
    {
        if(currentAsyncStart != null)
        {
            throw "Can only have one async assert at one time";
        }

        if (currentFunctionName != functionNameForAsyncToFinish)
        {
            throw "assertAsyncStart function and current function mismatch";
        }

        currentAsyncStart = cast currentTest;

        var currentAsyncTry: Null<Int> = testRunner.currentTestAttemptsLeft;

        testRunner.currentTestIsAsync = true;

        RunLoop.getMainLoop().delay(function()
        {
            if (currentFunctionName != functionNameForAsyncToFinish || currentAsyncStart != currentTest ||
                currentAsyncTry != testRunner.currentTestAttemptsLeft || testRunner == null)
            {
                return; /// not the current test anymore
            }

            currentTest.error = "Async timeout";
            currentTest.success = false;

            clearAsync();
            testRunner.endTest(currentTest);

        }, timeoutInSeconds);
    }

    public function assertAsyncFinish(functionNameForAsyncToFinish: String): Void
    {
        if (currentFunctionName != functionNameForAsyncToFinish || currentAsyncStart != currentTest)
        {
            return; /// timeout happened before
        }

        currentTest.done = true;

        clearAsync();

        testRunner.endTest();
    }

    public function assertShouldFail(): Void
    {
        testRunner.currentTestShouldFail = true;
    }

    public function clearAsync(): Void
    {
        currentAsyncStart = null;
    }

    function assertAsyncTrue(functionNameForAsyncToFinish: String, b:Bool, ?c : PosInfos): Void
    {
        if (currentFunctionName != functionNameForAsyncToFinish || currentAsyncStart != currentTest || currentAsyncStart != currentTest)
        {
            return; /// not this test anymore
        }

        super.assertTrue(b, c);
    }

    function assertAsyncFalse(functionNameForAsyncToFinish : String, b:Bool, ?c : PosInfos): Void
    {
        if (currentFunctionName != functionNameForAsyncToFinish || currentAsyncStart != currentTest || currentAsyncStart != currentTest)
        {
            return; /// not this test anymore
        }

        super.assertFalse(b, c);
    }

    function assertAsyncEquals<T>(functionNameForAsyncToFinish: String, expected: T , actual: T,  ?c : PosInfos): Void
    {
        if (currentFunctionName != functionNameForAsyncToFinish || currentAsyncStart != currentTest || currentAsyncStart != currentTest)
        {
            return; /// not this test anymore
        }

        super.assertEquals(expected, actual, c);
    }

    function assertThat<T>(actual:Dynamic, ?matcher:Matcher<T>, ?reason:String, ?info:PosInfos)
    {
        Matchers.assertThat(actual, matcher, reason, info);

        assertTrue(true);
    }
}
