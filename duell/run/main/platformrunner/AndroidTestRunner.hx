package duell.run.main.platformrunner;

import duell.objects.DuellProcess;
import duell.objects.HXCPPConfigXML;
import duell.helpers.HXCPPConfigXMLHelper;
import duell.helpers.LogHelper;
import duell.run.main.helpers.Emulator;

import haxe.io.Path;

class AndroidTestRunner extends TestingPlatformRunner
{

	private static inline var DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP = 1;
	private static inline var DEFAULT_ARMV7_EMULATOR = "duellarmv7";
	private var emulator : Emulator;
	private var adbPath : String;

	public function new()
	{
		super("android");
	}

	override public function prepareTestRun() : Void
	{
		super.prepareTestRun();

		setAdbPath();
		startEmulator();
		waitForEmulatorReady();
		uninstallApp();
	}

	override public function runTests() : Void 
	{
		installAndStartApp();
	}

	override public function closeTests() : Void
	{
		shutdownEmulator();
	}

	private function setAdbPath()
	{
		var hxcppConfig = HXCPPConfigXML.getConfig(HXCPPConfigXMLHelper.getProbableHXCPPConfigLocation());
        var defines : Map<String, String> = hxcppConfig.getDefines();
        adbPath = Path.join([defines.get("ANDROID_SDK"), "platform-tools"]);
	}

	private function uninstallApp()
	{
		var args = ["shell", "pm", "uninstall", config.getPackage()];

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

	private function installAndStartApp()
	{
		var args = ["install", "-r", getAppPath()];

        LogHelper.info("Installing with '" + "adb " + args.join(" ") + "'");
        var adbProcess = new DuellProcess(
                                        adbPath,
                                        "adb",
                                        args,
                                        {
                                            timeout : 300,
                                            logOnlyIfVerbose : false,
                                            shutdownOnError : true,
                                            block : true,
                                            errorMessage : "installing on device"
                                        });

       	duell.helpers.ThreadHelper.runInAThread(function()
            {
                Sys.sleep(DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP);
                runActivity();
            }
        );

       	runListener();
	}

	private function runActivity()
    {
        var args = ["shell", "am", "start", "-a", "android.intent.action.MAIN", "-n", config.getPackage() + "/" + config.getPackage() + "." + "MainActivity"];

        var adbProcess = new DuellProcess(
                                        adbPath,
                                        "adb",
                                        args,
                                        {
                                            timeout : 60,
                                            logOnlyIfVerbose : false,
                                            shutdownOnError : true,
                                            block : true,
                                            errorMessage : "running the app on the device"
                                        });
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