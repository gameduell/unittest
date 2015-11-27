package duell.run.main.platformrunner;

import duell.objects.Arguments;
import duell.helpers.ThreadHelper;
import duell.helpers.CommandHelper;

import haxe.io.Path;
import sys.io.File;

class IOSTestRunner extends TestingPlatformrunner
{
	
	public function new()
	{
		super('ios');
	}

	override function runTests() : Void
	{
		/// RUN THE APP IN A THREAD
		ThreadHelper.runInAThread(runApp);

		runListener();
	}

	private function runApp()
	{
		var arguments = Arguments.isSet('-simulator') ? "runsimulator_args" : "rundevice_args";
		var argsString = File.getContent(Path.join([unitTestLibPath, "configurations", platform, arguments]));
		argsString = StringTools.replace(argsString, "::PATH::", Arguments.get('-path'));
		var args = argsString.split("\n");
		args = args.filter(function(str) return str != "");

		if(Arguments.isSet('-simulator'))
		{
			var launcher = Path.join([unitTestLibPath , "bin", "ios-sim"]);
			CommandHelper.runCommand("", "chmod", ["+x", launcher], {errorMessage: "setting permissions on the simulator launcher"});

			var launcherPath = Path.directory(launcher);
			CommandHelper.runCommand(launcherPath, "ios-sim", args, {systemCommand: false, errorMessage: "running the simulator"});
		}
		else
		{
			var launcher = Path.join([unitTestLibPath , "bin", "ios-deploy"]);
			CommandHelper.runCommand("", "chmod", ["+x", launcher], {errorMessage: "setting permission on the ios deploy tool"});

			CommandHelper.runCommand("", launcher, args, {errorMessage: "deploying the app into the device"});
		}
	}
}