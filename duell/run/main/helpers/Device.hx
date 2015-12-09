package duell.run.main.helpers;

import duell.run.main.emulator.Emulator;

enum DeviceState {
	OFFLINE;
	ONLINE;
	UNAUTHORIZED;
	UNKNOWN;
}

class Device
{
	public var name(default, default) : String;
	public var arch(default, default) : EmulatorArchitecture;
	public var port(default, default) : String;
	public var state(default, default) : DeviceState = UNKNOWN;
	public var pid(default, default) : String;

	public function new()
	{
	}

	public function setDeviceState( state : String )
	{
		this.state = getDeviceState(state);
	}

	private function getDeviceState( value : String ) : DeviceState
	{
		value = value.toLowerCase();

		switch( value ){
			case 'offline' : return OFFLINE;
			case 'device' : return ONLINE;
			case 'unauthorized' : return UNAUTHORIZED;
			default : return UNKNOWN;
		}
	}

	public function isOnline() : Bool
	{
		return state == ONLINE;
	}

	public function toString() : String 
	{
		return "Name:" + name + " Port:" + port + " State:" + state + " Arch:" + arch + " Pid:" + pid;
	}
}