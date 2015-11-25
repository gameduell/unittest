package duell.run.main;


import duell.objects.Arguments;

import duell.helpers.LogHelper;

class RunMain
{
	public function new()
	{
	}

	public static function main()
	{
		if (!Arguments.validateArguments())
        {
            return;
        }

        new RunMain().setupTests();
	}

	public function setupTests()
	{
		specifyTestingPlatform();
        runTests();
	}

	private function specifyTestingPlatform()
	{
		LogHelper.info("==> " + Arguments.isSet("-path") + " " + Arguments.get("-path"));
	}

	private function runTests()
	{

	}
}