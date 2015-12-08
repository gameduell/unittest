package duell.run.main.emulator.commands;

import duell.run.main.emulator.Emulator;
import duell.objects.DuellProcess;

class GetDeviceArchitectureCommand implements IEmulatorCommand
{
	
	private var name : String;
	public var arch(default, null) : EmulatorArchitecture;

	public function new( name:String )
	{
		this.name = name;
	}

	public function execute( adbPath:String ) : Void
	{
		var proc = new DuellProcess(
			adbPath,
			"adb",
			["-s", name, "shell", "getprop", "ro.product.cpu.abi"],
			{
				timeout : 0,
				logOnlyIfVerbose : true,
				loggingPrefix : "[ADB]",
				shutdownOnError : false,
				block : true,
				errorMessage : "getting device architecture",
				systemCommand: false
			});

		var output = proc.getCompleteStdout().toString();
		var errorOutput = proc.getCompleteStderr().toString();

		if ( output != null )
		{
			if( output.indexOf('x86') != -1 )
			{
				arch = X86;
			}
			else if( output.indexOf('armeabi') != -1)
			{
				arch = ARM;
			}
		}
	}
}