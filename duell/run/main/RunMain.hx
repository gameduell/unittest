package duell.run.main;

import sys.FileSystem;

import duell.defines.DuellDefines;
import duell.objects.Arguments;
import duell.helpers.LogHelper;
import duell.run.main.platformrunner.ITestingPlatformRunner;
import duell.run.main.platformrunner.AndroidTestRunner;
import duell.run.main.platformrunner.IOSTestRunner;
import duell.run.main.platformrunner.HTML5TestRunner;

import haxe.Timer;

class RunMain
{
	public static function main()
	{
		var stamp : Float = Timer.stamp();

		if (!Arguments.validateArguments())
        {
            return;
        }

        if(!Arguments.isSet("-path")){
        	LogHelper.exitWithFormattedError("Use '-path' to define the path to your unittest project compilation.");
        }

        new RunMain().init();

        stamp = Timer.stamp() - stamp;

        LogHelper.info("USED TIME: " + stamp + " sec");
	}

	public function new()
	{
	}

	public function init()
	{
		setupTests();
	}

	public function setupTests()
	{
		var platformRunner = specifyTestingPlatform();
		if(platformRunner != null)
		{
			platformRunner.validateArguments();

			platformRunner.prepareTestRun();

     		platformRunner.runTests();

     		platformRunner.closeTests();
		}
		else
		{
			LogHelper.exitWithFormattedError("Unknown platform!");
		}
	}

	private function hasProjectFile() : Bool
	{
		return FileSystem.exists(DuellDefines.PROJECT_CONFIG_FILENAME);
	}

	private function specifyTestingPlatform() : ITestingPlatformRunner
	{
		if(Arguments.isSet("-android"))
		{
			return new AndroidTestRunner();
		}
		
		if(Arguments.isSet("-ios"))
		{
			return new IOSTestRunner();
		}

		if(Arguments.isSet("-html5"))
		{
			return new HTML5TestRunner();
		}

		return null;
	}
}