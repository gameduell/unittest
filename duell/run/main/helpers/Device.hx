package duell.run.main.helpers;

import duell.run.main.helpers.Emulator;

enum DeviceState {
	OFFLINE;
	ONLINE;
	UNAUTHORIZED;
	UNKNOWN;
}

class Device
{
	private static inline var DELIMETER = "-";

	public var arch(default, default) : EmulatorArchitecture;
	public var port(default, default) : String;
	public var state(default, default) : DeviceState = UNKNOWN;
	public var pid(default, default) : String;

	public function new()
	{
	}

	public function getName() : String
	{
		return "emulator" + DELIMETER + port;
	}

	public function parseName( name : String )
	{
		if(name == null || name.length == 0 || name.charAt(0) == '*')
			return;

		var parts = name.split(DELIMETER);
		port = parts.length >= 2 ? parts[1] : null;
	}

	public function setDeviceState( state : String )
	{
		this.state = getDeviceState(state);
	}

	private function getDeviceState( value : String ) : DeviceState
	{
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

	public function isComplete() : Bool
	{
		return port != null && state != null;
	}

	public function toString() : String 
	{
		return "Name:" + getName() + " Port:" + port + " State:" + state + " Arch:" + arch + " Pid:" + pid;
	}
}