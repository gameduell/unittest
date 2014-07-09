/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 08/07/14
 * Time: 10:31
 */
package unittest;

import haxe.unit.TestStatus;

enum TestStatusType
{
    TestStatusTypeSuccessful;
    TestStatusTypeSuccessfulShouldFail;
    TestStatusTypeFailure;
    TestStatusTypeError;
    TestStatusTypeWarningNoAssert;
}

class TestStatus extends haxe.unit.TestStatus
{
    public var testResultType : TestStatusType;

    public function new() : Void
    {
        super();
    }

}