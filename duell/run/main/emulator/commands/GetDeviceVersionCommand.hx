package duell.run.main.emulator.commands;

import duell.run.main.emulator.Emulator;
import duell.objects.DuellProcess;

class GetDeviceVersionCommand implements IEmulatorCommand
{
	
	private var name : String;
	public var version(default, null) : String;

	public function new( name:String )
	{
		this.name = name;
	}

	public function execute( adbPath:String ) : Void
	{
		var proc = new DuellProcess(
			adbPath,
			"adb",
			["-s", name, "shell", "getprop", "ro.build.version.release"],
			{
				timeout : 0,
				logOnlyIfVerbose : true,
				loggingPrefix : "[ADB]",
				shutdownOnError : false,
				block : true,
				errorMessage : "getting android version ",
				systemCommand: false
			});

		version = proc.getCompleteStdout().toString();
	}
}