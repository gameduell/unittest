package duell.run.main.platformrunner;

import duell.objects.DuellProcess;
import duell.objects.HXCPPConfigXML;
import duell.helpers.HXCPPConfigXMLHelper;
import duell.run.main.helpers.Emulator;

import haxe.io.Path;

class AndroidTestRunner extends TestingPlatformRunner
{

	private static inline var DEFAULT_ARMV7_EMULATOR = "duellarmv7";
	private var emulator : Emulator;

	public function new()
	{
		super("android");
	}

	override public function prepareTestRun() : Void
	{
		super.prepareTestRun();

		startEmulator();
		waitForEmulatorReady();
	}

	override public function runTests() : Void 
	{
		uninstallApp();
		// installApp();
		// runListener();
	}

	override public function closeTests() : Void
	{
		shutdownEmulator();
	}

	private function uninstallApp()
	{
		var hxcppConfig = HXCPPConfigXML.getConfig(HXCPPConfigXMLHelper.getProbableHXCPPConfigLocation());
        var defines : Map<String, String> = hxcppConfig.getDefines();
		var args = ["shell", "pm", "uninstall", config.getPackage()];
		var adbPath = Path.join([defines.get("ANDROID_SDK"), "platform-tools"]);

        var adbProcess = new DuellProcess(
        adbPath,
        "adb",
        args,
        {
        	timeout : 60,
        	logOnlyIfVerbose : false,
        	shutdownOnError : false,
        	block : true,
        	errorMessage : "uninstalling the app from the device"
        });
	}

	private function installApp()
	{
		// var args = ["install", "-r", Path.join([projectDirectory, "build", "outputs", "apk", Configuration.getData().APP.FILE+ "-" + (isDebug ? "debug" : "release") + ".apk"])];

  //       LogHelper.info("Installing with '" + "adb " + args.join(" ") + "'");
  //       var adbProcess = new DuellProcess(
  //                                       adbPath,
  //                                       "adb",
  //                                       args,
  //                                       {
  //                                           timeout : 300,
  //                                           logOnlyIfVerbose : false,
  //                                           shutdownOnError : true,
  //                                           block : true,
  //                                           errorMessage : "installing on device"
  //                                       });
	}

	private function startEmulator()
	{
		emulator = new Emulator(DEFAULT_ARMV7_EMULATOR, ARM);
		emulator.start();
	}

	private function waitForEmulatorReady()
	{
		emulator.waitUntilReady();
	}

	private function shutdownEmulator()
    {
        if (emulator == null)
            return;

        emulator.shutdown();
    }
}