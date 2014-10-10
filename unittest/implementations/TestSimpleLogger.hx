/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 09/07/14
 * Time: 10:38
 */
package unittest.implementations;

import haxe.Log;
using StringTools;
import unittest.Utils;

class TestSimpleLogger implements unittest.TestLogger
{
    public function new ()
    {

    }

    public function setup() : Void
    {

    }

    public function finish(result : TestResult, onFinishedCallback : TestLogger -> Void) :  Void
    {
        print(result.toString());

        onFinishedCallback(this);
    }

    public function logStartCase(currentCase : TestCase) : Void
    {
        print( "Class: " + Type.getClassName(Type.getClass(currentCase)) + " ");
    }

    private var currentTest : TestStatus;
    public function logStartTest(currentTest : TestStatus) : Void
    {
        this.currentTest = currentTest;
    }

    public function logEndCase() : Void
    {
        print("\n");
    }

    public function logEndTest() : Void
    {
        switch(currentTest.testResultType)
        {
            case TestStatusTypeSuccessful:
                print(".");
            case TestStatusTypeSuccessfulShouldFail:
                print(".");
            case TestStatusTypeFailure:
                print("F");
            case TestStatusTypeError:
                print("E");
            case TestStatusTypeWarningNoAssert:
                print("W");
        }

    }

    private var logMessageHandler : Dynamic -> Void = null;
    public function setLogMessageHandler(logMessageHandler : Dynamic -> Void)
    {
        this.logMessageHandler = logMessageHandler;
    }

    public dynamic function print( v : Dynamic ) untyped
    {
        if(logMessageHandler != null)
        {
            logMessageHandler(v);
            return;
        }

        Utils.print(v);
    }



}