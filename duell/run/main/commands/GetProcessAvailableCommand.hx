package duell.run.main.commands;

import duell.objects.DuellProcess;
import duell.helpers.LogHelper;

class GetProcessAvailableCommand
{
	private var pid : String;
	private var process : DuellProcess;
	public var processExisting(default, null) : Bool;

	public function new( pid : String )
	{
		this.pid = pid;
	}

	public function run()
	{
		processExisting = true;

		try{
			process = new DuellProcess(null, "ps", ["-p", pid],
					{
						systemCommand   : true,
						block           : true,
						shutdownOnError : true,
						mute            : true,
						errorMessage    : "Could not run 'ps -p " + pid + "'"
					});
		}
		catch(e : Dynamic)
		{
			processExisting = false;
		}
	}
}