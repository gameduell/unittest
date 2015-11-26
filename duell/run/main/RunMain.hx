package duell.run.main;


import duell.objects.Arguments;
import duell.helpers.LogHelper;
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

        new RunMain().setupTests();
	}

	public function new()
	{

	}

	public function setupTests()
	{
		var platformRunner = specifyTestingPlatform();
		if(platformRunner != null)
		{
			platformRunner.prepareTestRun();

     		platformRunner.runTests();

     		platformRunner.closeTests();
		}
		else
		{
			LogHelper.exitWithFormattedError("Unknown platform!");
		}
	}

	private function specifyTestingPlatform() : ITestingPlatformRunner
	{
		if(Arguments.isSet("-android")){
			return new AndroidTestRunner();
		}

		return null;
	}
}