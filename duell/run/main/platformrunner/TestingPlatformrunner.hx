package duell.run.main.platformrunner;

import duell.run.main.helpers.UnitTestConfig;
import duell.helpers.PathHelper;
import duell.helpers.LogHelper;
import duell.helpers.TestHelper;
import sys.FileSystem;

import duell.objects.Arguments;

import haxe.io.Path;

class TestingPlatformRunner implements ITestingPlatformRunner
{
	private var config : IUnitTestConfig;
	private var testResultFile : String;
	private var platform : String;

	public function new(platform : String)
	{
		this.platform = platform;
		var testResultPath = Path.join([Sys.getCwd(), "Export", "unittests"]);
		testResultFile = Path.join([testResultPath, resultFileName()]);
	}

	public function prepareTestRun() : Void
	{
		// DELETE PREVIOUS TEST
        if (sys.FileSystem.exists(testResultFile))
        {
            sys.FileSystem.deleteFile(testResultFile);
        }
        
        /// CREATE TARGET FOLDER
        PathHelper.mkdir(Path.directory(testResultFile));
	}

	private function runListener()
	{
		var testPort : Int = Arguments.isSet("-port") ? Arguments.get("-port") : 8181;

        /// RUN THE LISTENER
        TestHelper.runListenerServer(300, testPort, testResultFile);
	}

	public function runTests() : Void 
	{	
	}

	public function closeTests() : Void
	{
	}

	private function getAppPath() : String
	{
		return Arguments.get("-path");
	}


	private function resultFileName() : String
	{
		return 'test_result_' + platform + '.xml';
	}

	public function setConfig(value : IUnitTestConfig)
	{
		config = value;
	}

}