package duell.run.main.helpers;

import duell.run.main.emulator.Emulator;
import duell.objects.DuellProcess;
import duell.helpers.LogHelper;

import haxe.io.Path;

class Devices
{

	private static inline var EMULATOR_NAME = "emulator";
	private static var devices : Array<Device>;

	private static function setADBPath()
	{
	}

	public static function setup( adbPath:String )
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

        LogHelper.info("", "Devices: \n" + devices);
	}

	public static function getDeviceByName( name:String ) : Device
	{
		for (d in devices)
		{
			if ( d.getName() == name )
				return d;
		}

		return null;
	}

	public static function createNewDevice() : Device
	{
		var port = 5554 + Std.random(125);
		
		if (port % 2 > 0)
		{
			port += 1;
		}

		var device = new Device();
		device.port = Std.string(port);

		devices.push(device);

		return device;
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

			var device = getExistingDevice(row);
			if(device != null)
			{
				devices.push(device);
			}
		}
	}

	private static function getExistingDevice( entry:String ) : Device
	{
		var raw = unifyDeviceEntry(entry);
		var parts = raw.split(" ");
		var device : Device = null;

		if(parts.length >= 2)
		{
			device = new Device();
			device.parseName(parts[0]);
			device.setDeviceState(parts[1]);
		}

		if(device == null || !validDevice(device))
			return null;

		return device;
	}

	/**
	 * function validDevice
	 * Checks if the parameters of the Device object are valid.
	 *
	 * @param device Device
	**/
	private static function validDevice( device:Device ) : Bool
	{
		return device.isComplete();
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