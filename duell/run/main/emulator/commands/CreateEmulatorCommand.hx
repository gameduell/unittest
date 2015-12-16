package duell.run.main.emulator.commands;

import duell.objects.Arguments;
import duell.objects.HXCPPConfigXML;
import duell.objects.DuellProcess;
import duell.helpers.PlatformHelper;
import duell.helpers.HXCPPConfigXMLHelper;

import duell.run.main.helpers.Device;

import haxe.io.Path;

class CreateEmulatorCommand implements IEmulatorCommand
{
	private var device : Device;
	private var emulatorName : String;
	private var emulatorPath : String;
	private var emulatorProcess : DuellProcess;

	public function new( emulatorName:String, device:Device  )
	{
		this.emulatorName = emulatorName;
		this.device = device;

		setEmulatorPath();
	}

	private function setEmulatorPath()
	{
		var hxcppConfig = HXCPPConfigXML.getConfig(HXCPPConfigXMLHelper.getProbableHXCPPConfigLocation());
		var defines : Map<String, String> = hxcppConfig.getDefines();
		emulatorPath = Path.join([defines.get("ANDROID_SDK"), "tools"]);
	}

	public function execute( adbPath:String ) : Void
	{
		var args = ["-avd", emulatorName,
					"-prop", "persist.sys.language=en",
					"-prop", "persist.sys.country=GB",
					"-port", "" + device.port,
					"-no-snapshot-load", "-no-snapshot-save",
					"-gpu", "on", "-noaudio",
					"-no-window", "-no-skin"];

		if (Arguments.isSet("-wipeemulator"))
		{
			args.push("-wipe-data");
		}

		var emulator = "emulator";
		var actualEmulatorPath = emulatorPath;
		if (PlatformHelper.hostPlatform == Platform.WINDOWS)
		{
			if (device.arch != null)
			{
				switch (device.arch)
				{
					case ARM:
						emulator = "../emulator-arm.exe";
						actualEmulatorPath = Path.join([emulatorPath, "lib"]);
					case X86:
						emulator = "../emulator-x86.exe";
						actualEmulatorPath = Path.join([emulatorPath, "lib"]);
					default:
				}
			}
		}

		emulatorProcess = new DuellProcess(
										actualEmulatorPath,
										emulator,
										args,
										{
											timeout : 0,
											logOnlyIfVerbose : true,
											loggingPrefix : "[Emulator]",
											shutdownOnError : false,
											block : false,
											errorMessage : "running emulator",
											systemCommand: false
										});

		device.pid = Std.string( emulatorProcess.getPid() );
	}
}