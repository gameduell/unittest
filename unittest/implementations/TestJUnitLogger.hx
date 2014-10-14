/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 28/07/14
 * Time: 10:38
 */
package unittest.implementations;

import haxe.Log;
using StringTools;
import unittest.Utils;

class TestJUnitLogger implements unittest.TestLogger
{    
    public function new ()
    {

    }

    public function setup() : Void
    {
    	print("<testsuites>" + "\n");
    }

    public function finish(result : TestResult, onFinishedCallback : TestLogger -> Void) :  Void
    {
    	print("</testsuites>" + "\n");

        onFinishedCallback(this);
    }

    public function logStartCase(currentCase : TestCase) : Void
    {

        var fieldNames = Type.getInstanceFields(Type.getClass(currentCase));

        var functionNames = fieldNames.filter( function (val) {
            var field = Reflect.field(currentCase, val);
            return StringTools.startsWith(val, "test") && Reflect.isFunction(field);
        });


    	print("<testsuite name=\"" + Type.getClassName(Type.getClass(currentCase)) + "\" currentCasetests=\"" + functionNames.length + "\">" + "\n");
    }

    private var currentTest : TestStatus;
    public function logStartTest(currentTest : TestStatus) : Void
    {
        this.currentTest = currentTest;
    }

    public function logEndCase() : Void
    {
    	print("</testsuite>" + "\n");
    }

    public function logEndTest() : Void
    {
        switch(currentTest.testResultType)
        {
            case TestStatusTypeSuccessful:
				print("<testcase classname=\"" + currentTest.classname + "\" name=\"" + currentTest.method + "\" time=\"" + (currentTest.timeEnded - currentTest.timeStarted) + "\" />" + "\n");
            case TestStatusTypeSuccessfulShouldFail:
				print("<testcase classname=\"" + currentTest.classname + "\" name=\"" + currentTest.method + "\" time=\"" + (currentTest.timeEnded - currentTest.timeStarted) + "\" />" + "\n");
            case TestStatusTypeFailure:
				print("<testcase classname=\"" + currentTest.classname + "\" name=\"" + currentTest.method + "\" time=\"" + (currentTest.timeEnded - currentTest.timeStarted) + "\" >" + "\n");
				print("<failure type=\"" + "Failure" + "\">" + "\n");
				if(currentTest.posInfos != null)
            		print(currentTest.posInfos.fileName+":" + currentTest.posInfos.lineNumber + ": " + currentTest.error + "\n");
            	else
            		print(currentTest.error + "\n");
				print("</failure>" + "\n");
				print("</testcase>" + "\n");
            case TestStatusTypeError:
				print("<testcase classname=\"" + currentTest.classname + "\" name=\"" + currentTest.method + "\" time=\"" + (currentTest.timeEnded - currentTest.timeStarted) + "\" >" + "\n");
				print("<error type=\"" + "Error" + "\">" + "\n");
				if(currentTest.posInfos != null)
            		print(currentTest.posInfos.fileName+":" + currentTest.posInfos.lineNumber + ": " + currentTest.error + "\n");
            	else
            		print(currentTest.error + "\n");
				print("</error>" + "\n");
				print("</testcase>" + "\n");
            case TestStatusTypeWarningNoAssert:
				print("<testcase classname=\"" + currentTest.classname + "\" name=\"" + currentTest.method + "\" time=\"" + (currentTest.timeEnded - currentTest.timeStarted) + "\" >" + "\n");
				print("<failure type=\"" + "Failure" + "\">");
				if(currentTest.posInfos != null)
            		print(currentTest.posInfos.fileName+":" + currentTest.posInfos.lineNumber + ": " + currentTest.error + "\n");
            	else
            		print(currentTest.error + "\n");
				print("</failure>" + "\n");
				print("</testcase>" + "\n");
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