package duell.run.main;

import sys.FileSystem;

import duell.defines.DuellDefines;
import duell.objects.Arguments;
import duell.helpers.LogHelper;
import duell.run.main.helpers.UnitTestConfig;
import duell.run.main.platformrunner.ITestingPlatformRunner;
import duell.run.main.platformrunner.AndroidTestRunner;
import duell.run.main.platformrunner.IOSTestRunner;
import duell.run.main.platformrunner.HTML5TestRunner;

class RunMain
{
	
	public static function main()
	{
		if (!Arguments.validateArguments())
        {
            return;
        }

        if(!Arguments.isSet("-path")){
        	LogHelper.exitWithFormattedError("Use '-path' to define the path to your unittest project compilation.");
        }

        new RunMain().init();
	}

	public function new()
	{
	}

	public function init()
	{		
		if(!hasProjectFile())
		{
			LogHelper.exitWithFormattedError('No project file found.');
		}        

		setupTests();
	}

	public function setupTests()
	{
		var platformRunner = specifyTestingPlatform();
		if(platformRunner != null)
		{
			var config = UnitTestConfig.getConfig();
			config.parse();

			platformRunner.setConfig(config);

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