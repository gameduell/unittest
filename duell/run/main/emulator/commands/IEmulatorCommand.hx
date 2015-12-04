package duell.run.main.emulator.commands;

interface IEmulatorCommand
{
	function execute( adbPath : String ) : Void;
}