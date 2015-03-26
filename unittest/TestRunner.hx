/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 02/07/14
 * Time: 16:26
 */
package unittest;

import unittest.TestCase;
import unittest.TestLogger;
import unittest.TestStatus;

import logger.Logger;

import haxe.CallStack;
import haxe.Timer;
import haxe.rtti.Meta;

import runloop.RunLoop;

using Lambda;

import haxe.unit.TestRunner;
class TestRunner extends haxe.unit.TestRunner
{
    private var loggerList : Array<TestLogger>;

    private var currentCase : unittest.TestCase;
    private var currentCaseClass : Dynamic;
    private var currentTest : TestStatus;

    private var currentCaseTestFunctionNames : Array<String>;

    @:allow(unittest.TestCase)
    private var currentTestIsAsync : Bool;

    @:allow(unittest.TestCase)
    private var currentTestShouldFail : Bool;

    var onComplete:Void->Void;
    
    var caseIndex:Int = 0;
    var testIndex:Int = 0;

    private var oldTrace : Dynamic;

    public function new(onComplete: Void->Void) : Void
    {
        loggerList = new Array<TestLogger>();

        this.onComplete = onComplete;

        currentTestIsAsync = false;
        currentTestShouldFail = false;

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

        try
        {
            result = new TestResult();
        }
        catch (e: Dynamic)
        {
            onError(e);
        }

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

        } else {

            finishCase();
            nextCase();
        }
    }

    private function startTest() : Void
    {
        var functionName = currentCaseTestFunctionNames[testIndex];

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

        if(currentTestIsAsync)
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

        result.add(currentCase.currentTest);

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