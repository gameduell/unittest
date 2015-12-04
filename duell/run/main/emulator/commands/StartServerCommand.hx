package duell.run.main.emulator.commands;

import duell.objects.DuellProcess;

class StartServerCommand implements IEmulatorCommand
{
	public function new()
	{
	}

	public function execute( adbPath : String ) : Void 
	{
		new DuellProcess(
			adbPath,
			"adb",
			["start-server"],
			{
				timeout : 0,
				logOnlyIfVerbose : true,
				loggingPrefix : "[ADB]",
				shutdownOnError : false,
				block : true,
				errorMessage : "restarting adb",
				systemCommand: false
			});
	}
}