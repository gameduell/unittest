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

	/**
	 * function parseFile
	 * Parses the configuration file and creates the configured/used devices.
	 *
	 * @param content String
	**/
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

	/**
	 * function createDeviceEntry
	 * Based on the passed device it will create a certain entry for the configuration file.
	 *
	 * @param d Device 
	**/
	private function createDeviceEntry( d : Device ) : String 
	{
		return d.arch + DELIMETER + d.getName() + DELIMETER + d.pid;
	}

	/**
	 * function writeFile
	 * Writes the content from <br>fileContent</br> to configuration file.
	**/
	private function writeFile()
	{
		var fileOutput = File.write(filePath, false);
		fileOutput.writeString(fileContent.join('\n'));
		fileOutput.close();
	}

	/**
	 * function removeDevice
	 * Removes a device of the passed architecture from file.
	 *
	 * @param arch EmulatorArchitecture
	**/
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

	/**
	 * function addDevice
	 * Adds a device of the passed architecture to file. If a device of this architecture 
	 * already exist, it will be removed.
	 *
	 * @param arch EmulatorArchitecture
	**/
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

	/**
	 * function hasDeviceForArchitecture
	 * Checks if a device for the passed architecture was used / is configured.
	 *
	 * @param arch EmulatorArchitecture
	 * @return Bool true if it a device is configured, else false
	**/
	public function hasDeviceForArchitecture( arch : EmulatorArchitecture ) : Bool
	{
		for ( d in devices )
			if( d.arch == arch )
				return true;

		return false;
	}

	/**
	 * function isArchitectureDevice
	 * At some point you don't know the architecture of a device from the device list of the emulator. For this
	 * purpose it's needed to check this device against the configured one and the architecture for which the 
	 * unittests should run.
	 *
	 * @param arch EmulatorArchitecture
	 * @param device Device
	 * @return Bool true if the device is setted up for the passed architecture, else false
	**/
	public function isArchitectureDevice( arch : EmulatorArchitecture, device : Device ) : Bool
	{
		for ( d in devices )
			if( d.getName() == device.getName() && d.arch == arch )
				return true;

		return false;
	}
}