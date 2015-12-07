package duell.run.main.commands;

import duell.objects.DuellProcess;

class KillProcessCommand
{
	private var pid : String;

	public function new( pid:String )
	{
		this.pid = pid;
	}

	public function run()
	{
		new DuellProcess(null, "kill", ["-9", pid], 
				{
					systemCommand   : true,
					block           : true,
					shutdownOnError : true,
					errorMessage    : "Could not shutdown process with pid '" + pid + "'"
				});
	}
}