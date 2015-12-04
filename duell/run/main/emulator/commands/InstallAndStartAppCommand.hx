package duell.run.main.emulator.commands;

import duell.objects.DuellProcess;
import duell.helpers.ThreadHelper;

import duell.run.main.helpers.Device;
import duell.run.main.helpers.DefaultServerListenerHelper;

class InstallAndStartAppCommand implements IEmulatorCommand
{	
	private static inline var DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP = 1;
	private var device : Device;
	private var appPath : String;
	private var appPackage : String;
	private var listener : DefaultServerListenerHelper;

	public function new( device:Device, appPath:String, appPackage:String, listener : DefaultServerListenerHelper )
	{
		this.device = device;
		this.appPath = appPath;
		this.appPackage = appPackage;
		this.listener = listener;
	}

	public function execute( adbPath:String ) : Void
	{
		var args = ["-s", device.getName() , "install", "-r", appPath, "-netfast"];

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

       	ThreadHelper.runInAThread(function()
            {
                Sys.sleep(DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP);
                runActivity(adbPath);
            }
        );

       	listener.runListener();
	}

	private function runActivity( adbPath:String )
	{
		var args = ["-s", device.getName(), "shell", "am", "start", "-a", "android.intent.action.MAIN", "-n", appPackage + "/" + appPackage + "." + "MainActivity"];

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