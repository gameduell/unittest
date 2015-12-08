/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package duell.run.main.emulator;

import duell.objects.HXCPPConfigXML;
import duell.objects.DuellProcess;
import duell.helpers.HXCPPConfigXMLHelper;
import duell.helpers.LogHelper;
import duell.run.main.helpers.Device;
import duell.run.main.emulator.commands.IEmulatorCommand;

import haxe.io.Path;

enum EmulatorArchitecture
{
	X86;
	ARM;
	/// MIPS not supported
}

@:access(duell.objects.DuellProcess)
class Emulator
{

	public static function getEmulatorArchitechture( value:String ) : EmulatorArchitecture
	{
		switch( value )
		{
			case 'X86' : return X86;
			case 'ARM' : return ARM;
		}

		return null;
	}

	private static inline var EMULATOR_IS_RUNNING_TIME_TO_CHECK = 3;
	private static inline var SECONDS_BEFORE_GIVINGUP_ON_EMULATOR_LAUNCHING = 300;

	private var adbPath: String;
	private var devices: Array<Device>;
	private var device : Device;

	public function new(): Void
	{
	}

	public function initialize()
	{
		var hxcppConfig = HXCPPConfigXML.getConfig(HXCPPConfigXMLHelper.getProbableHXCPPConfigLocation());
		var defines : Map<String, String> = hxcppConfig.getDefines();
		adbPath = Path.join([defines.get("ANDROID_SDK"), "platform-tools"]);

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

	public function getRunningEmulatorDevice() : Device
	{
		for ( d in devices )
		{
			if ( d.isOnline() )
				return d;
		}

		return null;
	}

	private function parse( list:String )
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

	private function getExistingDevice( entry:String ) : Device
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

		if(device == null || !validEmulatorDevice(device))
			return null;

		return device;
	}

	/**
	 * function validDevice
	 * Checks if the parameters of the Device object are valid.
	 *
	 * @param device Device
	**/
	private function validEmulatorDevice( device:Device ) : Bool
	{
		return device.isComplete();
	}

	public function getDeviceByName( name:String ) : Device
	{
		// return Devices.getDeviceByName( name );
		for (d in devices)
		{
			if ( d.getName() == name )
				return d;
		}

		return null;
	}

	public function useDevice( d:Device )
	{
		device = d;
	}

	public function createDevice( arch:EmulatorArchitecture ) : Device
	{
		
		var port = 5554 + Std.random(125);
		
		if (port % 2 > 0)
		{
			port += 1;
		}

		var device = new Device();
		device.port = Std.string(port);
		device.arch = arch;

		devices.push(device);

		return device;
	}

	/**
	 * function unifyDeviceEntry
	 * Removes spaces except one and returns the result string
	 *
	 * @param entry String
	 * @return result String with reduced whitespaces
	**/
	private function unifyDeviceEntry( entry : String ) : String
	{
		var regEx = ~/\s/g;

		return regEx.replace(entry, ' ');
	}

	public function runEmulator( commands:Array<IEmulatorCommand> )
	{
		for ( i in 0...commands.length )
		{
			commands[i].execute( adbPath );
		}
	}

	public function getCurrentDevice() : Device 
	{
		return device;
	}
}
