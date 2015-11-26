package duell.run.main.platformrunner;

interface ITestingPlatformRunner
{
	function prepareTestRun() : Void;
	function runTests() : Void;
	function closeTests() : Void;
}