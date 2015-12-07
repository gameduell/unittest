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
import duell.run.main.helpers.Device;
import duell.run.main.helpers.Devices;
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

	private var emulatorProcess: DuellProcess;
	private var adbPath: String;
	private var device : Device;

	public function new(): Void
	{
	}

	public function initialize()
	{
		var hxcppConfig = HXCPPConfigXML.getConfig(HXCPPConfigXMLHelper.getProbableHXCPPConfigLocation());
		var defines : Map<String, String> = hxcppConfig.getDefines();
		adbPath = Path.join([defines.get("ANDROID_SDK"), "platform-tools"]);

		Devices.setup( adbPath );
	}

	public function getDeviceByName( name:String ) : Device
	{
		return Devices.getDeviceByName( name );
	}

	public function useDevice( d:Device )
	{
		device = d;
	}

	public function createDevice( arch:EmulatorArchitecture ) : Device
	{
		device = Devices.createNewDevice();
		device.arch = arch;

		return device;
	}

	public function runEmulator( commands:Array<IEmulatorCommand> )
	{
		for ( i in 0...commands.length )
		{
			commands[i].execute( adbPath );
		}
	}

	public function shutdown(): Void
	{
		if (emulatorProcess != null)
			emulatorProcess.kill();
	}

	public function getCurrentDevice() : Device 
	{
		return device;
	}
}
