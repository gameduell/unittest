package duell.run.main.platformrunner;

import duell.objects.DuellProcess;
import duell.objects.Arguments;
import duell.objects.DuellLib;
import duell.helpers.ThreadHelper;
import duell.helpers.CommandHelper;
import duell.helpers.LogHelper;

import haxe.io.Path;
import sys.io.File;

class IOSTestRunner extends TestingPlatformRunner
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
		var lib = DuellLib.getDuellLib( dependedLibrary );

		var arguments = Arguments.isSet('-simulator') ? "runsimulator_args" : "rundevice_args";
		var argsString = File.getContent(Path.join([unitTestLibPath, "configurations", platform, arguments]));
		argsString = StringTools.replace(argsString, "::PATH::", getAppPath());
		var args = argsString.split("\n");
		args = args.filter(function(str) return str != "");

		if(Arguments.isSet('-simulator'))
		{
			var launcher = Path.join([lib.getPath() , "bin", "ios-sim"]);
			CommandHelper.runCommand("", "chmod", ["+x", launcher], {errorMessage: "setting permissions on the simulator launcher"});

			var launcherPath = Path.directory(launcher);
			CommandHelper.runCommand(launcherPath, "ios-sim", args, {systemCommand: false, errorMessage: "running the simulator"});
		}
		else
		{
			var launcher = Path.join([lib.getPath(), "bin", "ios-deploy"]);
			CommandHelper.runCommand("", "chmod", ["+x", launcher], {errorMessage: "setting permission on the ios deploy tool"});

			CommandHelper.runCommand("", launcher, args, {errorMessage: "deploying the app into the device"});
		}
	}

	override public function closeTests() : Void
	{
		var xcodeVersion = getXCodeMajorVersion();
		var args = xcodeVersion > 6 ? ["Simulator"] : ["iOS Simulator"];

		try
		{
			CommandHelper.runCommand("", "killall", args, {errorMessage: "stopping simulator"});
		}
		catch (e:Dynamic)
		{
			LogHelper.info("Stopping the simulator wasn't successful");
		}
	}

	private function getXCodeMajorVersion() : Int
	{
		var proc = new DuellProcess("", "xcodebuild", ["-version"], {block:true, logOnlyIfVerbose:true, systemCommand:true, errorMessage: "Trying to get xcode version"});
        var output = proc.getCompleteStdout().toString();//output should be something like 'Xcode 7.2'

        try
        {
			var parts = output.split("\n"); ////['Xcode 7.2', 'Build version 7C68']
			parts = parts[0].split(" ");//[Xcode,7.2]
        	var returnedVersion = parts.length > 1 ? parts[1] : parts[0];
        	var versions = returnedVersion.split(".");//[7,2]

        	return Std.parseInt(versions[0]);
        }
        catch( e:Dynamic )
        {
        	return 0;
        }
	}
}