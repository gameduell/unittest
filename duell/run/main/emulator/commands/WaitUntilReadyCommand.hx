package duell.run.main.emulator.commands;

import haxe.Timer;

import duell.helpers.LogHelper;
import duell.objects.DuellProcess;

import duell.run.main.helpers.Device;

class WaitUntilReadyCommand implements IEmulatorCommand
{

	private static inline var EMULATOR_IS_RUNNING_TIME_TO_CHECK = 3;
	private static inline var SECONDS_BEFORE_GIVINGUP_ON_EMULATOR_LAUNCHING = 300;
	private var device : Device;

	public function new( device : Device )
	{
		this.device = device;
	}

	/**
	 * function execute
	 *
	 * IEmulatorCommand implementations
	**/
	public function execute( adbPath : String ) : Void
	{
		var timeStarted = Timer.stamp();

		var argsConnect = ["connect", "localhost:" + device.port];
		var argsBoot = ["-s", device.name, "shell", "getprop", "dev.bootcomplete"];

		var opts = {
			timeout : 0.0,
			mute: false,
			shutdownOnError : false,
			block : true,
			errorMessage : "checking if emulator is connected",
			systemCommand: false
		};

		var alreadyConnected = false;
		var startKillCounter = 10;

		while (true)
		{
			if (!alreadyConnected && startKillCounter == 0)
			{
				var kill = new KillServerCommand();
				kill.execute( adbPath );

				var start = new StartServerCommand();
				start.execute( adbPath );
				// adbKillStartServer();

				startKillCounter = 10;
			}
			if (timeStarted + SECONDS_BEFORE_GIVINGUP_ON_EMULATOR_LAUNCHING < Timer.stamp())
			{
				throw "time out connecting to the emulator";
			}

			if(alreadyConnected)
				LogHelper.info("Booting the emulator...");
			else
				LogHelper.info("Trying to connect to the emulator...");

			if (!alreadyConnected)
			{
				new DuellProcess(adbPath, "adb", argsConnect, opts);
			}

			var proc = new DuellProcess(adbPath, "adb", argsBoot, opts);
			var output = proc.getCompleteStdout().toString();
			var outputError = proc.getCompleteStderr().toString();

			if (output.indexOf("1") != -1)
			{
				break;
			}

			if (outputError.indexOf("device not found") != -1)
			{
				alreadyConnected = false;
			}
			else if(outputError.indexOf("device offline") != -1)
			{
				alreadyConnected = false;
			}
			else
			{
				alreadyConnected = true;
			}

			startKillCounter--;
			Sys.sleep(EMULATOR_IS_RUNNING_TIME_TO_CHECK);
		}
	}
}