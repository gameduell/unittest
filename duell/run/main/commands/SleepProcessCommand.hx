package duell.run.main.commands;

import duell.objects.DuellProcess;

class SleepProcessCommand
{
	private var pid : String;

	public function new( pid:String )
	{
		this.pid = pid;
	}

	public function run()
	{
		new DuellProcess(null, "kill", ["-STOP", pid], 
				{
					systemCommand   : true,
					block           : true,
					shutdownOnError : true,
					errorMessage    : "Could not shutdown process with pid '" + pid + "'"
				});
	}
}