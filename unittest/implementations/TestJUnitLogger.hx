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
 
package unittest.implementations;

import haxe.Log;
import logger.Logger;

using StringTools;

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

        Logger.print(v);
    }
}
