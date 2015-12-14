package duell.run.main.helpers;

import duell.objects.DuellProcess;
import duell.helpers.ThreadHelper;

class FetchLogcatHelper
{
	private var device : Device;
	private var logOutputProc : DuellProcess;
	private var resultLog = '';

	public function new( device:Device )
	{
		this.device = device;
	}

	public function clearLog( adbPath:String )
    {
        var args = ["-s", device.name, "shell", "logcat", "-c"];

        var clearProc = new DuellProcess(
                                    adbPath,
                                    "adb",
                                    args,
                                    {
                                        timeout : 0,
                                        logOnlyIfVerbose : true,
                                        shutdownOnError : false,
                                        block : true,
                                        errorMessage : "clearing the log"
                                    });
    }

	public function fetchLog( adbPath:String ) : Void
	{
		if( logOutputProc != null ) return;

		var args = ["-s", device.name, "shell", "logcat", "-v", "raw", "-s", "duell:I"];

		logOutputProc = new DuellProcess(
							adbPath,
							"adb",
							args,
							{
								timeout : 0,
                                logOnlyIfVerbose : true,
                                shutdownOnError : false,
                                block : false,
                                errorMessage : "fetching the log"
                            });
	}

	public function getLog() : String
	{
		if( logOutputProc != null)
		{
			logOutputProc.kill();

			resultLog = logOutputProc.getCompleteStdout().toString();

			logOutputProc = null;
		}
		
		return resultLog;
	}
}
