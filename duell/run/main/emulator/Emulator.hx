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
import duell.run.main.emulator.commands.GetDeviceArchitectureCommand;
import duell.run.main.emulator.commands.GetDeviceVersionCommand;

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
		value = value.toUpperCase();

		switch( value )
		{
			case 'X86' : return X86;
			case 'ARM' : return ARM;
		}

		return null;
	}

	private static inline var EMULATOR_IS_RUNNING_TIME_TO_CHECK = 3;
	private static inline var SECONDS_BEFORE_GIVINGUP_ON_EMULATOR_LAUNCHING = 300;
	private static inline var EMULATOR_NAME_DELIMETER = "-";

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

        setDeviceInformations();

        LogHelper.info("", "Devices: \n" + devices);
	}

	private function setDeviceInformations()
	{
		for ( d in devices )
		{
			if( d.isOnline() )
			{
				var dArchitecture = getDeviceArchitecture( d );
				d.arch = dArchitecture;

				d.setVersion( getDeviceAndroidVersion( d ) );
			}
		}
	}

	public function getRunningEmulatorDevice( arch:EmulatorArchitecture ) : Device
	{
		for ( d in devices )
		{
			if ( d.isOnline() )
			{
				if( d.arch == arch )
				{
					return d;
				}

			}
		}
		
		return null;
	}

	private function getDeviceArchitecture( device:Device ) : EmulatorArchitecture
	{
		var proc = new GetDeviceArchitectureCommand( device.name );
		proc.execute( adbPath );

		return proc.arch;
	}

	private function getDeviceAndroidVersion( device:Device ) : String
	{
		var proc = new GetDeviceVersionCommand( device.name );
		proc.execute( adbPath );

		return proc.version;
	}

	private function parse( list:String )
	{
		devices = new Array<Device>();

		var deviceList = list.split('\n');
		var row : String;
		for (i in 0...deviceList.length)
		{
			row = deviceList[i];

			if(i == 0 || row.length == 0 || row.charAt(0) == '*') // headline, empty row or adb info line
				continue;

			var device = parseExistingDevice( row );
			if(device != null)
			{
				devices.push( device );
			}
		}
	}

	private function parseExistingDevice( entry:String ) : Device
	{
		var raw = unifyDeviceEntry(entry);
		var parts = raw.split(" ");
		var device : Device = null;

		if(parts.length >= 2)
		{
				device = new Device();
				device.name = parts[0];
				device.port = getDevicePort( device.name );
				device.setDeviceState(parts[1]);
		}

		return device;
	}

	private function getDevicePort( deviceName:String ) : String
	{
		return isEmulatorDevice( deviceName ) ? deviceName.split(EMULATOR_NAME_DELIMETER)[1] : Std.string( getRandomPort() );
	}

	public function isEmulatorDevice( name:String ) : Bool
	{
		var parts = name.split(EMULATOR_NAME_DELIMETER);

		return parts.length == 2 && parts[0] == 'emulator' && parts[1].length == 4 ? true : false;
	}

	public function getDeviceByName( name:String ) : Device
	{
		for (d in devices)
		{
			if ( d.name == name )
				return d;
		}

		return null;
	}

	public function useDevice( d:Device )
	{
		device = d;
	}

	public function createEmulatorDevice( arch:EmulatorArchitecture ) : Device
	{
		var port = getRandomPort(); 

		var device = new Device();
		device.port = Std.string( port );
		device.name = "emulator" + EMULATOR_NAME_DELIMETER + device.port;
		device.arch = arch;

		devices.push( device );

		return device;
	}

	private function getRandomPort() : Int
	{
		var port = 5554 + Std.random(125);
		
		if (port % 2 > 0)
		{
			port += 1;
		}

		return port;
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
