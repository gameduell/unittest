package duell.run.main.helpers;

import sys.FileSystem;
import sys.io.File;

import haxe.io.Path;

import duell.helpers.LogHelper;
import duell.helpers.DuellConfigHelper;
import duell.run.main.helpers.Emulator;

class DeviceFileHelper
{
	
	private static inline var DELIMETER : String = ' ';
	private static var FILE : String = 'run_unittest.config';
	private var devices : Array<Device>;
	private var filePath : String = null;
	private var fileContent : Array<String>;

	public function new()
	{
		init();
	}

	/**
	 * function init()
	 * Reads the config file or creates one if it isn't existing and parses the configured devices.
	**/
	private function init()
	{
		filePath = Path.join([DuellConfigHelper.getDuellConfigFolderLocation(), '.tmp', FILE]);
		
		if(!FileSystem.exists(filePath))
		{
			var fileOutput = File.write(filePath, false);
			fileOutput.close();
		}

		var content = File.getContent(filePath);
		parseFile(content);
	}

	private function parseFile( content : String )
	{
		devices = new Array<Device>();
		fileContent = content.split('\n');
		fileContent = fileContent.filter(function(s) {
			return s.length != 0;
		});

		var d : String;
		for (i in 0...fileContent.length)
		{
			d = fileContent[i];
			if( d.length == 0 )
				continue;

			fileContent[i] = ~/\n/g.replace(fileContent[i], '');

			var parsed = d.split(DELIMETER);
			var device = new Device();
			device.arch = Emulator.getEmulatorArchitechture(parsed[0]);
			device.parseName(parsed[1]);
			device.pid = parsed[2];

			devices.push(device);
		}

		LogHelper.info("result: " + devices);
	}

	private function createDeviceEntry( d : Device ) : String 
	{
		return d.arch + DELIMETER + d.getName() + DELIMETER + d.pid;
	}

	private function writeFile()
	{
		var fileOutput = File.write(filePath, false);
		fileOutput.writeString(fileContent.join('\n'));
		fileOutput.close();
	}

	public function removeDevice( arch : EmulatorArchitecture ) : Bool
	{
		for (i in 0...devices.length)
		{
			var d = devices[i];
			if( d.arch == arch )
			{
				devices.splice(i, 1);
				fileContent.splice(i, 1);
				writeFile();

				return true;
			}

		}

		return false;
	}

	public function addDevice( arch : EmulatorArchitecture, device : Device ) : Bool
	{
		device.arch = arch;

		if(hasDeviceForArchitecture( arch ))
		{
			removeDevice( arch );
		}
		
		devices.push( device );
		fileContent.push( createDeviceEntry(device) );
		writeFile();

		return true;
	}

	public function hasDeviceForArchitecture( arch : EmulatorArchitecture ) : Bool
	{
		for ( d in devices )
			if( d.arch == arch )
				return true;

		return false;
	}

	public function isArchitectureDevice( arch : EmulatorArchitecture, device : Device ) : Bool
	{
		for ( d in devices )
			if( d.getName() == device.getName() && d.arch == arch )
				return true;

		return false;
	}
}