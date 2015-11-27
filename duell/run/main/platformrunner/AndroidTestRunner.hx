package duell.run.main.platformrunner;

import duell.objects.DuellProcess;
import duell.objects.HXCPPConfigXML;
import duell.helpers.HXCPPConfigXMLHelper;
import duell.helpers.LogHelper;
import duell.helpers.TestHelper;
import duell.run.main.helpers.Emulator;

import haxe.io.Path;

class AndroidTestRunner extends TestingPlatformRunner
{

	private static inline var DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP = 1;
	private static inline var DEFAULT_ARMV7_EMULATOR = "duellarmv7";
	private var emulator : Emulator;
	// private var logcatProcess: DuellProcess = null; /// will block here if emulator is not running.
	private var adbPath : String;

	public function new()
	{
		super("android");
	}

	override public function prepareTestRun() : Void
	{
		LogHelper.info("...prepareTestRun...");
		super.prepareTestRun();

		setAdbPath();
		startEmulator();
		waitForEmulatorReady();
		uninstallApp();
	}

	override public function runTests() : Void 
	{
		LogHelper.info("...runTests...");
		installAndStartApp();
		// runLogcat();
	}

	override public function closeTests() : Void
	{
		LogHelper.info("...closeTests...");
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
		// var args = ["install", "-r", Path.join([projectDirectory, "build", "outputs", "apk", Configuration.getData().APP.FILE+ "-" + (isDebug ? "debug" : "release") + ".apk"])];
		// /Users/clue/Developer/haXe/game_engine_tests/Export/android/engineTests/build/outputs/apk/engineTests-release.apk
		
		//TODO clue
		var args = ["install", "-r", '/Users/clue/Developer/haXe/game_engine_tests/Export/android/engineTests/build/outputs/apk/engineTests-release.apk'];

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

        var testPort:Int = 8181;//untyped Configuration.getData().TEST_PORT == null ?
            // 8181 : Configuration.getData().TEST_PORT;

        /// RUN THE LISTENER
        TestHelper.runListenerServer(300, testPort, testResultFile);
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

    // private function runLogcat()
    // {
    //     var args = ["logcat"];


        // if (!isFullLogcat)
        // {
        //     var filter = "*:E";
        //     var includeTags = ["duell", "Main", "DuellActivity", "GLThread", "trace"];

        //     for (tag in includeTags)
        //     {
        //         filter += " " + tag + ":D";
        //     }
        //     args = args.concat([filter]);
        // }


    //     logcatProcess = new DuellProcess(
    //                                     adbPath,
    //                                     "adb",
    //                                     args,
    //                                     {
    //                                         logOnlyIfVerbose : false,
    //                                         loggingPrefix: "[LOGCAT]",
    //                                         errorMessage : "running logcat"
    //                                     });
    // }

	private function startEmulator()
	{
		emulator = new Emulator(DEFAULT_ARMV7_EMULATOR, ARM);
		emulator.start();

		// Sys.sleep(10);
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