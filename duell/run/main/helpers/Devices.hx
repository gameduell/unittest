package duell.run.main.helpers;

import duell.objects.HXCPPConfigXML;
import duell.objects.DuellProcess;

import duell.helpers.LogHelper;
import duell.helpers.HXCPPConfigXMLHelper;

import haxe.io.Path;

class Devices
{
	private static var adbPath : String;
	private static var devices : Array<Device>;

	private static function setADBPath()
	{
		var hxcppConfig = HXCPPConfigXML.getConfig(HXCPPConfigXMLHelper.getProbableHXCPPConfigLocation());
		var defines : Map<String, String> = hxcppConfig.getDefines();
		adbPath = Path.join([defines.get("ANDROID_SDK"), "platform-tools"]);
	}

	public static function setup()
	{
		setADBPath();

		var adbProcess = new DuellProcess(
        adbPath,
        "adb",
        ["devices"],
        {
        	timeout : 60,
        	logOnlyIfVerbose : false,
        	shutdownOnError : false,
        	block : true,
        	mute : true,
        	errorMessage : "displaying the devices"
        });

        var output = adbProcess.getCompleteStdout().toString();
        parse(output);

        LogHelper.info("found devices:\n" + devices);
	}

	private static function parse( list:String )
	{
		devices = new Array<Device>();

		var deviceList = list.split('\n');
		var row : String;
		for (i in 0...deviceList.length)
		{
			row = deviceList[i];

			if(i == 0 || row.length == 0) // headline or empty row
				continue;

			var device = getDevice(row);
			if(device != null)
			{
				devices.push(device);
			}
		}
	}

	private static function getDevice( entry:String ) : Device
	{
		var raw = unifyDeviceEntry(entry);
		var parts = raw.split(" ");
		var device : Device = null;

		if(parts.length >= 2)
		{
			device = new Device(parts[0], parts[1]);
		}

		if(device == null || !validDevice(device))
			return null;

		return device;
	}

	private static function validDevice( device:Device ) : Bool
	{
		if(device == null)
			return false;

		if(device.name.charAt(0) == '*')
			return false;

		if(device.name.length == 0 || device.state.length == 0)
			return false;

		return true;
	}

	/**
	 * function unifyDeviceEntry
	 * Removes spaces except one and returns the result string
	 *
	 * @param entry String
	 * @return result String with reduced whitespaces
	**/
	private static function unifyDeviceEntry( entry : String ) : String
	{
		var regEx = ~/\s/g;

		return regEx.replace(entry, ' ');
	}
}


class Device
{
	private static inline var STATE_ONLINE = 'device';

	public var name(default, null) : String;
	public var state(default, null) : String;

	public function new( name:String, state:String )
	{
		this.name = name;
		this.state = state;
	}

	public function isOnline() : Bool
	{
		return state == STATE_ONLINE;
	}

	public function toString() : String
	{
		return "Device name:" + name + " state:" + state;
	}
}