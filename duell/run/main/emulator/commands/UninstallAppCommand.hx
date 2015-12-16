package duell.run.main.emulator.commands;

import duell.objects.DuellProcess;

class UninstallAppCommand implements IEmulatorCommand
{

	private var deviceName : String;
	private var appPackage : String;

	public function new( deviceName:String, appPackage:String )
	{
		this.deviceName = deviceName;
		this.appPackage = appPackage;
	}

	public function execute( adbPath:String ) : Void
	{
		var args = ["-s", deviceName, "shell", "pm", "uninstall", appPackage];

        var adbProcess = new DuellProcess(
        adbPath,
        "adb",
        args,
        {
        	timeout : 60,
        	logOnlyIfVerbose : false,
        	shutdownOnError : false,
        	block : true,
        	errorMessage : "uninstalling the app from the device"
        });
	}
}