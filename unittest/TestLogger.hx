/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 07/07/14
 * Time: 12:10
 */
package unittest;

import unittest.TestResult;
import unittest.TestCase;
import unittest.TestStatus;


interface TestLogger
{
    public function setup() : Void;

    public function finish(result : TestResult, onFinishedCallback : TestLogger -> Void) :  Void;

    public function logStartCase(currentCase : TestCase) : Void;

    public function logStartTest(currentTest : TestStatus) : Void;

    public function logEndCase() : Void;

    public function logEndTest() : Void;

    /// by default the log will be written to standard output
    public function setLogMessageHandler(logMessageHandler : Dynamic -> Void) : Void;
}