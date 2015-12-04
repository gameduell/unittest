package duell.run.main.platformrunner;

import duell.objects.DuellProcess;
import duell.objects.HXCPPConfigXML;
import duell.objects.Arguments;
import duell.helpers.HXCPPConfigXMLHelper;
import duell.helpers.LogHelper;
import duell.helpers.ThreadHelper;
import duell.run.main.helpers.Device;
import duell.run.main.helpers.DeviceFileHelper;
import duell.run.main.commands.GetProcessAvailableCommand;
import duell.run.main.commands.ContinueProcessCommand;
import duell.run.main.commands.SleepProcessCommand;
import duell.run.main.emulator.Emulator;
import duell.run.main.emulator.commands.IEmulatorCommand;
import duell.run.main.emulator.commands.CreateEmulatorCommand;
import duell.run.main.emulator.commands.WaitUntilReadyCommand;
import duell.run.main.emulator.commands.UninstallAppCommand;
import duell.run.main.emulator.commands.InstallAndStartAppCommand;

import haxe.io.Path;

class AndroidTestRunner extends TestingPlatformRunner
{
	private static inline var DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP = 1;
	private static inline var DEFAULT_ARMV7_EMULATOR = "duellarmv7";
    private static inline var DEFAULT_X86_EMULATOR = "duellx86";
	private var emulator : Emulator;
    private var emulatorName : String = null;
    private var emulatorArch : EmulatorArchitecture = null;
	private var adbPath : String;
    private var deviceFile : DeviceFileHelper;
    private var device : Device;
    private var commands : Array<IEmulatorCommand>;

	public function new()
	{
		super("android");
	}

	override public function prepareTestRun() : Void
	{
		super.prepareTestRun();

        deviceFile = new DeviceFileHelper();

        setArchitecture();
        initializeEmulator();
        checkReuseEmulator();

		// setAdbPath();		
		// waitForEmulatorReady();
		// uninstallApp();
	}

	override public function runTests() : Void 
	{
		LogHelper.info("AndroidTestRunner :: runTests");

        // installAndStartApp();
        emulator.runEmulator( commands );
	}

	override public function closeTests() : Void
	{
        LogHelper.info("AndroidTestRunner :: closeTests");

        var d = emulator.getCurrentDevice();
        deviceFile.addDevice(emulatorArch, d);

        new SleepProcessCommand( d.pid ).run();

        // if(!Arguments.isSet('-keepEmulatorProcess'))
        // {
        //     shutdownEmulator();
        // }
        // if(emulator != null)
        // {
        //     emulator.stopDevice();
        // } 
	}

	// private function setAdbPath()
	// {
	// 	var hxcppConfig = HXCPPConfigXML.getConfig(HXCPPConfigXMLHelper.getProbableHXCPPConfigLocation());
 //        var defines : Map<String, String> = hxcppConfig.getDefines();
 //        adbPath = Path.join([defines.get("ANDROID_SDK"), "platform-tools"]);
	// }

    private function setArchitecture()
    {
        var isX86 = Arguments.isSet("-x86");

        if(isX86)
        {
            emulatorName = DEFAULT_X86_EMULATOR;
            emulatorArch = X86;
        }
        else
        {
            emulatorName = DEFAULT_ARMV7_EMULATOR;
            emulatorArch = ARM;
        }
    }

    private function initializeEmulator()
    {
        emulator = new Emulator(emulatorName, emulatorArch);
        emulator.initialize();
    }

    private function checkReuseEmulator()
    {
        var usedDevice = deviceFile.hasDeviceForArchitecture(emulatorArch);
        if( usedDevice != null )
        {
            var emulatorDevice = emulator.getDeviceByName(usedDevice.getName());
            if( emulatorDevice != null && emulatorDevice.isOnline() )
            {
                LogHelper.info("AndroidTestRunner :: reuse device!");
                // reuse the existing and running emulator
                emulatorDevice.arch = emulatorArch;
                emulatorDevice.pid = usedDevice.pid;
                
                emulator.useDevice(emulatorDevice);
                setupReuseProcess(emulatorDevice);
            }   
            else
            {
                LogHelper.info("AndroidTestRunner :: checkReuseEmulator : emulatorDevice not found or not online : " + emulatorDevice);
                setupNewProcess();
            }
        }
        else
        {
            LogHelper.info("AndroidTestRunner :: checkReuseEmulator : no used device found : " + usedDevice);
            setupNewProcess();
        }
    }

    private function setupReuseProcess( device : Device )
    {
        LogHelper.info("AndroidTestRunner :: setupReuseProcess :: device : " + device);

        //check process available, usually it's not needed to check, because if there is a running device, there must be process for it
        var checkProcessCmd = new GetProcessAvailableCommand(device.pid);
        checkProcessCmd.run();

        if( !checkProcessCmd.processExisting )
        {
            setupNewProcess();
            return;         
        }

        //awake process
        new ContinueProcessCommand( device.pid ).run();
        
        //create emulator commands
        commands = new Array<IEmulatorCommand>();
        commands.push(new WaitUntilReadyCommand( device ));
        commands.push(new UninstallAppCommand( device.getName(), config.getPackage() ));
        commands.push(new InstallAndStartAppCommand( device, getAppPath(), config.getPackage(), listener));
    }

    private function setupNewProcess()
    {
        LogHelper.info("AndroidTestRunner :: setupNewProcess ");
        var device = emulator.createDevice( emulatorArch );

        //create emulator commands
        commands = new Array<IEmulatorCommand>();
        commands.push(new CreateEmulatorCommand( emulatorName, device ));
        commands.push(new WaitUntilReadyCommand( device ));
        commands.push(new UninstallAppCommand( device.getName(), config.getPackage() ));
        commands.push(new InstallAndStartAppCommand( device, getAppPath(), config.getPackage(), listener));
    }

	// private function uninstallApp()
	// {
	// 	var args = ["-s", emulator.getDeviceName(), "shell", "pm", "uninstall", config.getPackage()];

 //        var adbProcess = new DuellProcess(
 //        adbPath,
 //        "adb",
 //        args,
 //        {
 //        	timeout : 60,
 //        	logOnlyIfVerbose : false,
 //        	shutdownOnError : false,
 //        	block : true,
 //        	errorMessage : "uninstalling the app from the device"
 //        });
	// }

	// private function installAndStartApp()
	// {
	// 	var args = ["-s", emulator.getDeviceName(), "install", "-r", getAppPath(), "-netfast"];

 //        var adbProcess = new DuellProcess(
 //                                        adbPath,
 //                                        "adb",
 //                                        args,
 //                                        {
 //                                            timeout : 300,
 //                                            logOnlyIfVerbose : false,
 //                                            shutdownOnError : true,
 //                                            block : true,
 //                                            errorMessage : "installing on device"
 //                                        });

 //       	ThreadHelper.runInAThread(function()
 //            {
 //                Sys.sleep(DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP);
 //                runActivity();
 //            }
 //        );

 //       	runListener();
	// }

	// private function runActivity()
 //    {
 //        var args = ["-s", emulator.getDeviceName(), "shell", "am", "start", "-a", "android.intent.action.MAIN", "-n", config.getPackage() + "/" + config.getPackage() + "." + "MainActivity"];

 //        var adbProcess = new DuellProcess(
 //                                        adbPath,
 //                                        "adb",
 //                                        args,
 //                                        {
 //                                            timeout : 60,
 //                                            logOnlyIfVerbose : false,
 //                                            shutdownOnError : true,
 //                                            block : true,
 //                                            errorMessage : "running the app on the device"
 //                                        });
 //    }

	// private function waitForEmulatorReady()
	// {
	// 	emulator.waitUntilReady();
	// }

	private function shutdownEmulator()
    {
        if (emulator == null)
            return;

        emulator.shutdown();
    }
}