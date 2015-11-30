package duell.run.main.platformrunner;

import duell.objects.DuellProcess;
import duell.objects.Server;
import duell.objects.Arguments;
import duell.helpers.PlatformHelper;
import duell.helpers.ThreadHelper;
import duell.helpers.CommandHelper;

import haxe.io.Path;

class HTML5TestRunner extends TestingPlatformRunner
{

	private static inline var DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP = 2;

	private var server : Server;
	private var slimerProcess : DuellProcess;

	public function new()
	{
		super('html5');
	}

	override public function runTests() : Void 
	{
		startHTTPServer();

		/// RUN THE APP IN A THREAD
		var targetTime = haxe.Timer.stamp() + DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP;
		ThreadHelper.runInAThread(function()
		{
			Sys.sleep(DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP);

			runApp();
		});

		try
		{
			runListener();
		}
		catch(e : Dynamic)
		{
			quit();

			throw e;
		}
	}

	private function startHTTPServer()
	{
		var serverTargetDirectory : String  = Arguments.get('-path');
		
 		server = new Server(serverTargetDirectory, -1, 3000);
        server.start();
	}

	//runs in slimerJS only
	private function runApp()
	{
		var slimerFolder: String;
		var xulrunnerFolder: String;
		var xulrunnerCommand: String;

 		if (PlatformHelper.hostPlatform == LINUX)
		{
			slimerFolder = "slimerjs_linux";
 			xulrunnerCommand = "xulrunner";
 		}
 		else if (PlatformHelper.hostPlatform == MAC)
 		{
			slimerFolder = "slimerjs_mac";
 			xulrunnerCommand = "xulrunner";
 		}
 		else
 		{
			slimerFolder = "slimerjs_win";
 			xulrunnerCommand = "xulrunner.exe";
 		}
		
		xulrunnerFolder = Path.join([unitTestLibPath,"bin", platform, slimerFolder,"xulrunner"]);
		var appPath = Path.join([unitTestLibPath, "bin", platform, slimerFolder, "application.ini"]);
	    var scriptPath = Path.join([unitTestLibPath, "bin", platform, "application.js"]);

		if (PlatformHelper.hostPlatform != WINDOWS)
		{
			CommandHelper.runCommand(xulrunnerFolder,
									 "chmod",
									 ["+x", "xulrunner"],
									 {systemCommand: true,
									 errorMessage: "Setting permissions for slimerjs"});
		}
		else
        {
			xulrunnerFolder = xulrunnerFolder.split("/").join("\\");
            xulrunnerCommand = xulrunnerCommand.split("/").join("\\");
		    appPath = appPath.split("/").join("\\");
            scriptPath = scriptPath.split("/").join("\\");
        }

		slimerProcess = new DuellProcess(
										xulrunnerFolder,
										xulrunnerCommand,
										["-app",
										appPath,
										"-no-remote",
										scriptPath, config.winWidth(), config.winHeight()],
										{
											logOnlyIfVerbose : true,
											systemCommand : false,
											errorMessage: "Running the slimer js browser"
										});

		slimerProcess.blockUntilFinished();
		
	}

	override public function closeTests() : Void
	{
		quit();
	}

	private function quit()
	{
		if (server != null)
		{
			server.shutdown();
		}
		
		if (slimerProcess != null)
		{
			slimerProcess.kill();
		}
	}
}