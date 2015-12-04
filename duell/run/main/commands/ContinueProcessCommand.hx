package duell.run.main.commands;

import duell.objects.DuellProcess;

class ContinueProcessCommand
{
	private var pid : String;

	public function new( pid:String )
	{
		this.pid = pid;
	}

	public function run()
	{
		new DuellProcess(null, "kill", ["-CONT", pid], 
				{
					systemCommand   : true,
					block           : true,
					shutdownOnError : true,
					errorMessage    : "Could not continue process with pid '" + pid + "'"
				});
	}
}