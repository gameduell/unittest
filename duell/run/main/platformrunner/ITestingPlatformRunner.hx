package duell.run.main.platformrunner;

interface ITestingPlatformRunner
{
    function validateArguments() : Void;
    function prepareTestRun() : Void;
    function runTests() : Void;
    function closeTests() : Void;
}