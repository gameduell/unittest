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
	public var state(default, default) : DeviceState = OFFLINE;


	public function new()
	{
	}

	public function getName() : String
	{
		return "emulator" + DELIMETER + arch + DELIMETER + port;
	}

	public function parseName( name : String )
	{
		if(name == null || name.length == 0 || name.charAt(0) == '*')
			return;

		var parts = name.split(DELIMETER);
		arch = parts.length >= 2 ? getArchitecture(parts[1]) : null;
		port = parts.length >= 3 ? parts[2] : null;
	}

	public function setDeviceState( state : String )
	{
		this.state = getDeviceState(state);
	}

	private function getArchitecture( value:String ) : EmulatorArchitecture
	{
		switch(value)
		{
			case 'ARM' : return ARM;
			case 'X86' : return X86;
		}

		return null;
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
		return arch != null && port != null && state != null;
	}

	public function toString() : String 
	{
		return "Device name:" + getName() + " arch:" + arch + " port:" + port + " state:" + state;
	}
}