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
	private var version : Version;

	public function new()
	{
	}

	public function setVersion( value:String )
	{
		version = new Version( value );
	}

	public function getMajorVersion() : Int 
	{
		return version != null ? version.major : 0;
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
		return "Name:" + name + " Port:" + port + " State:" + state + " Arch:" + arch + " Android-Version:" + version;
	}
}

class Version
{
	private var version : Array<String>;
	public var major(default, null) : Int;
	public var minor(default, null) : Int;
	public var patch(default, null) : Int;

	public function new( version:String )
	{
		this.version = new Array<String>();
		this.version = version.split(".");

		major = this.version.length >= 1 ? Std.parseInt( this.version[0] ) : 0;
		minor = this.version.length >= 2 ? Std.parseInt( this.version[1] ) : 0;
		patch = this.version.length >= 3 ? Std.parseInt( this.version[2] ) : 0;
	}

	public function toString() : String
	{
		return version.join(".");
	}
}
