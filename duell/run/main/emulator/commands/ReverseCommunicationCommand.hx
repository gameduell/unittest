package duell.run.main.emulator.commands;

import duell.run.main.helpers.Device;

import duell.objects.DuellProcess;

class ReverseCommunicationCommand implements IEmulatorCommand
{
	private var device : Device;

	public function new( device:Device )
	{
		this.device = device;
	}

	public function execute( adbPath:String ) : Void
	{
		var args = ["-s", device.name, "reverse", "tcp:8181", "tcp:8181"];

        var reverseProc = new DuellProcess(
                                    adbPath,
                                    "adb",
                                    args,
                                    {
                                        timeout : 60,
                                        logOnlyIfVerbose : true,
                                        shutdownOnError : true,
                                        block : true,
                                        errorMessage : "reversing communication"
                                    });  
	}
}