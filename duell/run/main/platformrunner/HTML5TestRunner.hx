package duell.run.main.platformrunner;

class HTML5TestRunner extends TestingPlatformRunner
{

	private static inline var DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP = 2;

	public function new()
	{
		super('html5');
	}

	override public function runTests() : Void 
	{
		/// RUN THE APP IN A THREAD
		var targetTime = haxe.Timer.stamp() + DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP;
		ThreadHelper.runInAThread(function()
		{
			Sys.sleep(DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP);

			runApp();
		});
	}
}