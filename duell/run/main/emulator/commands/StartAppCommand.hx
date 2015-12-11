package duell.run.main.emulator.commands;

import duell.objects.DuellProcess;
import duell.helpers.ThreadHelper;

import duell.run.main.helpers.Device;
import duell.run.main.helpers.DefaultServerListenerHelper;

class StartAppCommand implements IEmulatorCommand
{
	private static inline var DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP = 1;
	private var device : Device;
	private var appPackage : String;
	private var listener : DefaultServerListenerHelper;

	public function new( device:Device, appPackage:String, listener:DefaultServerListenerHelper )
	{
		this.device = device;
		this.appPackage = appPackage;
		this.listener = listener;
	}

	public function execute( adbPath:String ) : Void
	{
       	ThreadHelper.runInAThread(function()
            {
                Sys.sleep(DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP);
                runActivity( adbPath );
            }
        );

        listener.runListener(); 
	}

	private function runActivity( adbPath:String )
	{
		var args = ["-s", device.name, "shell", "am", "start", "-a", "android.intent.action.MAIN", "-n", appPackage + "/" + appPackage + "." + "MainActivity"];

        var adbProcess = new DuellProcess(
                                    adbPath,
                                    "adb",
							        args,
						            {
                                        timeout : 60,
                                        logOnlyIfVerbose : false,
                                        shutdownOnError : true,
                                        block : true,
                                        errorMessage : "running the app on the device"
                                    });
	}
}