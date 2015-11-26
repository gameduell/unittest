package duell.run.main;

import sys.FileSystem;

import duell.defines.DuellDefines;
import duell.objects.Arguments;
import duell.helpers.LogHelper;
import duell.run.main.helpers.UnitTestConfig;
import duell.run.main.platformrunner.ITestingPlatformRunner;
import duell.run.main.platformrunner.AndroidTestRunner;

class RunMain
{
	
	public static function main()
	{
		if (!Arguments.validateArguments())
        {
            return;
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
			platformRunner.setConfig(UnitTestConfig.getConfig());

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
		if(Arguments.isSet("-android")){
			return new AndroidTestRunner();
		}

		return null;
	}
}