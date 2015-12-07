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
import duell.run.main.commands.KillProcessCommand;
import duell.run.main.emulator.Emulator;
import duell.run.main.emulator.commands.IEmulatorCommand;
import duell.run.main.emulator.commands.CreateEmulatorCommand;
import duell.run.main.emulator.commands.WaitUntilReadyCommand;
import duell.run.main.emulator.commands.UninstallAppCommand;
import duell.run.main.emulator.commands.InstallAndStartAppCommand;
import duell.run.main.emulator.commands.KillServerCommand;
import duell.run.main.emulator.commands.StartServerCommand;

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
	}

	override public function runTests() : Void 
	{
        emulator.runEmulator( commands );
	}

	override public function closeTests() : Void
	{
        var d = emulator.getCurrentDevice();
        deviceFile.addDevice(emulatorArch, d);

        //new SleepProcessCommand( d.pid ).run();
	}

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
        emulator = new Emulator();
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
                // reuse the existing and running emulator
                emulatorDevice.arch = emulatorArch;
                emulatorDevice.pid = usedDevice.pid;
                LogHelper.info("", "Reuse existing emulator device: " + emulatorDevice);

                emulator.useDevice(emulatorDevice);
                setupReuseProcess(emulatorDevice);
            }   
            else
            {
                setupNewProcess();
            }
        }
        else
        {
            setupNewProcess();
        }
    }

    private function setupReuseProcess( device : Device )
    {
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
        killRunningEmulators();

        var device = emulator.createDevice( emulatorArch );
        emulator.useDevice( device );
        
        LogHelper.info("", "Created new emulator device: " + device);

        //create emulator commands
        commands = new Array<IEmulatorCommand>();
        commands.push(new KillServerCommand());
        commands.push(new StartServerCommand());
        commands.push(new CreateEmulatorCommand( emulatorName, device ));
        commands.push(new WaitUntilReadyCommand( device ));
        commands.push(new UninstallAppCommand( device.getName(), config.getPackage() ));
        commands.push(new InstallAndStartAppCommand( device, getAppPath(), config.getPackage(), listener));
    }

    private function killRunningEmulators()
    {
        var devicesInFile = deviceFile.devices;
        var device : Device = null;
        for ( d in devicesInFile )
        {
            device = emulator.getDeviceByName( d.getName() );
            if( device != null)
            {
                var proc = new GetProcessAvailableCommand( d.pid );
                proc.run();

                if( proc.processExisting )
                {
                    new KillProcessCommand( d.pid ).run();
                    deviceFile.removeDevice( d.arch );
                }
            }
        }
    }
}