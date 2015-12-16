package duell.run.main.platformrunner;

interface ITestingPlatformRunner
{
	function setConfig(value : IUnitTestConfig) : Void;
	function prepareTestRun() : Void;
	function runTests() : Void;
	function closeTests() : Void;
}