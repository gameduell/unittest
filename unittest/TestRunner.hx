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

import unittest.TestCase;
import unittest.TestLogger;
import unittest.TestStatus;

import msignal.Signal.Signal1;

import logger.Logger;

import haxe.CallStack;
import haxe.Timer;
import haxe.rtti.Meta;

import runloop.RunLoop;

using Lambda;

import haxe.unit.TestRunner;
class TestRunner extends haxe.unit.TestRunner
{
    private var loggerList: Array<TestLogger>;

    private var currentCase: unittest.TestCase;
    private var currentCaseClass: Dynamic;
    private var currentTest: TestStatus;

    private var currentCaseTestFunctionNames: Array<String>;

    @:allow(unittest.TestCase)
    private var currentTestIsAsync: Bool;

    @:allow(unittest.TestCase)
    private var currentTestShouldFail: Bool;

    @:allow(unittest.TestCase)
    private var currentTestAttemptsLeft: Null<Int>;

    var onComplete:Void->Void;

    var caseIndex:Int = 0;
    var testIndex:Int = 0;

    private var oldTrace : Dynamic;

    public function new(onComplete: Void->Void, onErrorSignal: Signal1<Dynamic>): Void
    {
        loggerList = new Array<TestLogger>();

        this.onComplete = onComplete;

        currentTestIsAsync = false;
        currentTestShouldFail = false;
        currentTestAttemptsLeft = null;

        onErrorSignal.add(onError);

        super();
    }

    /// ========= LOGGING =========

    public function addLogger(testLogger : TestLogger)
    {
        loggerList.push(testLogger);
    }

    private function logSetup() : Void
    {

        for(testLogger in loggerList)
        {
            testLogger.setup();
        }
    }

    private var loggersToFinish : Array<TestLogger>;
    private function logFinishAndExit() : Void
    {
        if(loggerList.length == 0)
        {
            onComplete();
        }

        loggersToFinish = new Array<TestLogger>();
        for(testLogger in loggerList)
        {
            loggersToFinish.push(testLogger);
            testLogger.finish(cast result, loggerFinished);
        }


    }

    private function loggerFinished(logger : TestLogger) : Void
    {
        loggersToFinish.remove(logger);

        if(loggersToFinish.length == 0)
        {
            onComplete();
        }

    }

    private function logStartCase() : Void
    {
        for(testLogger in loggerList)
        {
            testLogger.logStartCase(currentCase);
        }
    }

    private function logStartTest() : Void
    {
        for(testLogger in loggerList)
        {
            testLogger.logStartTest(cast currentCase.currentTest);/// on the base class, it is the haxe.unit version
        }
    }

    private function logEndTest() : Void
    {
        for(testLogger in loggerList)
        {
            testLogger.logEndTest();
        }

    }

    private function logEndCase() : Void
    {
        for(testLogger in loggerList)
        {
            testLogger.logEndCase();
        }
    }

    /// ==============================

    override function run() : Bool
    {
        logSetup();

        result = new TestResult();

        nextCase();

        return true;
    }

    override function add(c : haxe.unit.TestCase) : Void
    {
        if(!Std.is(c, unittest.TestCase))
            throw "unittest.TestRunner is only compatible with unittest.TestCase";

        cases.add(c);
    }

    private function onError(obj : Dynamic) : Void
    {
        if(currentTest != null)
            endTest(obj);
        else
            throw obj; /// is not running a test, so this is another problem

    }

    private function nextCase() : Void
    {
        RunLoop.getMainLoop().queue(_nextCase, PriorityASAP);
    }

    private function _nextCase() : Void
    {
        testIndex = 0;
        if (caseIndex < cases.length)
        {
            startCase();
            caseIndex++;

            nextTest();
        }
        else
        {
            finish();
        }
    }

    private function nextTest() : Void
    {
        RunLoop.getMainLoop().queue(_nextTest, PriorityASAP);
    }

    private function _nextTest() : Void
    {
        if (testIndex < currentCaseTestFunctionNames.length)
        {
            startTest();
        }
        else
        {
            finishCase();
            nextCase();
        }
    }

    private function startTest() : Void
    {
        var functionName = currentCaseTestFunctionNames[testIndex];

        if (currentTestAttemptsLeft == null)
        {
            // if it is null, it is a new test, so we check to see if it has the try metatag
            var classFields = Meta.getFields(currentCaseClass);
            var functionFields = Reflect.field(classFields, functionName);

            if (functionFields != null && Reflect.hasField(functionFields, "try"))
            {
                var tryTag: Array<Dynamic> = Reflect.field(functionFields, "try");
                var tryElement: Int = tryTag[0];

                currentTestAttemptsLeft = tryElement;
            }
        }

        testIndex++;

        currentTest = new unittest.TestStatus();

        currentTest.classname = Type.getClassName(currentCaseClass);
        currentTest.method = functionName;

        currentCase.currentTest = currentTest;

        logStartTest();

        currentCase.setup();

        currentTest.timeStarted = Timer.stamp();

        oldTrace = haxe.Log.trace;
        haxe.Log.trace = function customTrace( v, ?p : haxe.PosInfos )
        {
            var str = Std.string(v);
            Logger.print(p.fileName+":"+p.lineNumber+": "+str+(str.indexOf("\n") == -1 ? "\n" : ""));
        };

        currentCase.currentFunctionName = functionName;

        Reflect.callMethod(currentCase, Reflect.field(currentCase, functionName), new Array());

        if (currentTestIsAsync)
        {
            currentTestIsAsync = false;
        }
        else
        {
            endTest();
        }
    }

    @:allow(unittest.TestCase)
    private function endTest(e:Dynamic = null)
    {
        haxe.Log.trace = oldTrace;

        if (Std.is(e, unittest.TestStatus))
        {
            currentTest.testResultType = TestStatusTypeFailure;
            currentTest.backtrace = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
        }
        else if (e != null)
        {
            #if js
                if( e.message != null ){
                    currentTest.error = "exception thrown : "+e+" ["+e.message+"]";
                }else{
                    currentTest.error = "exception thrown : "+e;
                }
			#else
                currentTest.error = "exception thrown : "+e;
            #end

            currentTest.backtrace = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
            currentTest.testResultType = TestStatusTypeError;
        }
        else
        {
            if(currentTest.done)
            {
                currentTest.success = true;
                currentTest.testResultType = TestStatusTypeSuccessful;
            }
            else
            {
                currentTest.success = false;
                currentTest.error = "(warning) no assert";
                currentTest.testResultType = TestStatusTypeWarningNoAssert;
            }
        }

        if(currentTestShouldFail)
        {
            currentTest.success = !currentTest.success;

            if(currentTest.success)
                currentTest.testResultType = TestStatusTypeSuccessfulShouldFail;
            else
                currentTest.error = "test should have failed";
        }

        currentTestShouldFail = false;

        currentTest.timeEnded = Timer.stamp();

        logEndTest();

        if (currentTestAttemptsLeft != null)
        {
            // decrement test attempts
            currentTestAttemptsLeft--;

            if (currentTestAttemptsLeft <= 0 || currentTest.success)
            {
                // if it succeeded or there are no more attempts left, reset the state
                currentTestAttemptsLeft = null;
                result.add(currentCase.currentTest);
            }
            else
            {
                // repeat the same test
                testIndex = Std.int(Math.max(0, testIndex - 1));
            }
        }
        else
        {
            // log result as normal
            result.add(currentCase.currentTest);
        }

        currentCase.tearDown();
        currentCase.currentFunctionName = null;
        currentCase.currentAsyncStart = null;

        currentTest = null;

        nextTest();
    }

    private function startCase() : Void
    {
        currentCase = cast Lambda.array(cases)[caseIndex];
        currentCaseClass = Type.getClass(currentCase);

        var fieldNames = Type.getInstanceFields(currentCaseClass);

        currentCaseTestFunctionNames = fieldNames.filter( function (val) {
            var field = Reflect.field(currentCase, val);
            return StringTools.startsWith(val, "test") && Reflect.isFunction(field);
        }).array();

        currentCase.testRunner = this;

        logStartCase();
    }

    private function finishCase() : Void
    {
        logEndCase();

        currentCase.testRunner = null;
        currentCase = null;
    }


    function finish()
    {
        logFinishAndExit();
    }
}
