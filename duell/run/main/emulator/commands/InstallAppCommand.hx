package duell.run.main.emulator.commands;

import duell.objects.DuellProcess;
import duell.run.main.helpers.Device;

class InstallAppCommand implements IEmulatorCommand
{	
	private static inline var DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP = 1;
	private var device : Device;
	private var appPath : String;

	public function new( device:Device, appPath:String )
	{
		this.device = device;
		this.appPath = appPath;
	}

	public function execute( adbPath:String ) : Void
	{
		var args = ["-s", device.name , "install", "-r", appPath];

        var adbProcess = new DuellProcess(
                                        adbPath,
                                        "adb",
                                        args,
                                        {
                                            timeout : 300,
                                            logOnlyIfVerbose : false,
                                            shutdownOnError : true,
                                            block : true,
                                            errorMessage : "installing on device"
                                        });
	}
}