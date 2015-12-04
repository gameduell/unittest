package duell.run.main.helpers;

import duell.objects.Arguments;
import duell.helpers.TestHelper;

class DefaultServerListenerHelper
{

	private var testResultFile : String;

	public function new( testResultFile : String )
	{
		this.testResultFile = testResultFile;
	}

	public function runListener()
	{
		var testPort : Int = Arguments.isSet("-port") ? Arguments.get("-port") : 8181;

        /// RUN THE LISTENER
        TestHelper.runListenerServer(300, testPort, testResultFile);
	}
}