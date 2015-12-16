package duell.run.main.emulator.commands;

import duell.objects.DuellProcess;
import duell.helpers.ThreadHelper;
import duell.helpers.LogHelper;

import duell.run.main.helpers.Device;
import duell.run.main.helpers.FetchLogcatHelper;
import duell.run.main.helpers.DefaultServerListenerHelper;

import sys.io.File;

class StartAppCommand implements IEmulatorCommand
{
	private static inline var DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP = 1;
	private var device : Device;
	private var appPackage : String;
	private var listener : DefaultServerListenerHelper;
	private var logCatHelper : FetchLogcatHelper;

	public function new( device:Device, appPackage:String, listener:DefaultServerListenerHelper, ?logCatHelper:FetchLogcatHelper )
	{
		this.device = device;
		this.appPackage = appPackage;
		this.listener = listener;
		this.logCatHelper = logCatHelper;
	}

	public function execute( adbPath:String ) : Void
	{
		if(logCatHelper != null)
			runLogcatMode( adbPath );
		else
			runUsualMode( adbPath );
	}

	private function runLogcatMode( adbPath:String )
	{
		logCatHelper.clearLog( adbPath );
		
       	ThreadHelper.runInAThread(function()
            {
                Sys.sleep(DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP);
                logCatHelper.fetchLog( adbPath );
            }
        );

       	runActivity( adbPath );
	}

	private function runUsualMode( adbPath:String )
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

        if(logCatHelper != null)
        {
        	Sys.sleep(5);

        	var log = logCatHelper.getLog();
        	var content = log.split('\n');
        	content = content.filter(function(s){
        		return s != null && !StringTools.startsWith( s, '----');
        	});

			var fout = File.write(listener.testResultFile, false);
	        var resultString = content.join('\n');
		    fout.writeString(resultString);
	    	fout.close();
        	
        	LogHelper.info("TestResults:\n" + content.join('\n'));
        }
	}
}