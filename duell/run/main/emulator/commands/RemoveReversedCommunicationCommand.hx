package duell.run.main.emulator.commands;

import duell.objects.DuellProcess;

import duell.run.main.helpers.Device;

class RemoveReversedCommunicationCommand implements IEmulatorCommand
{
	private var device : Device;

	public function new( device:Device )
	{
		this.device = device;
	}

	public function execute( adbPath:String ) : Void
	{
		var args = ["-s", device.name, "reverse", "--remove-all"];

        var removeProc = new DuellProcess(
                                    adbPath,
                                    "adb",
                                    args,
                                    {
                                        timeout : 60,
                                        logOnlyIfVerbose : true,
                                        shutdownOnError : true,
                                        block : true,
                                        errorMessage : "remove reversed communication"
                                    });  
	}
}