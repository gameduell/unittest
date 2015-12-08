package duell.run.main.platformrunner;

import duell.objects.Arguments;
import duell.helpers.LogHelper;
import duell.run.main.helpers.Device;
import duell.run.main.emulator.Emulator;
import duell.run.main.emulator.commands.IEmulatorCommand;
import duell.run.main.emulator.commands.CreateEmulatorCommand;
import duell.run.main.emulator.commands.WaitUntilReadyCommand;
import duell.run.main.emulator.commands.UninstallAppCommand;
import duell.run.main.emulator.commands.InstallAndStartAppCommand;
import duell.run.main.emulator.commands.KillServerCommand;
import duell.run.main.emulator.commands.StartServerCommand;
import duell.run.main.emulator.commands.GetDeviceArchitectureCommand;

class AndroidTestRunner extends TestingPlatformRunner
{
	private static inline var DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP = 1;
	private static inline var DEFAULT_ARMV7_EMULATOR = "duellarmv7";
    private static inline var DEFAULT_X86_EMULATOR = "duellx86";
	private var emulator : Emulator;
    private var emulatorName : String = null;
    private var emulatorArch : EmulatorArchitecture = null;
    private var commands : Array<IEmulatorCommand>;

	public function new()
	{
		super("android");
	}

	override public function prepareTestRun() : Void
	{
		super.prepareTestRun();

        setArchitecture();
        initializeEmulator();
        checkReuseEmulator();
	}

	override public function runTests() : Void 
	{
        emulator.runEmulator( commands );
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
        var runningDevice = emulator.getRunningEmulatorDevice( emulatorArch );
        if ( runningDevice != null )
        {
            emulator.useDevice( runningDevice );
            setupReuseProcess( runningDevice );
        }
        else
        {
            setupNewProcess();
        }
    }

    private function setupReuseProcess( device : Device )
    {   
        //create emulator commands
        commands = new Array<IEmulatorCommand>();
        commands.push(new WaitUntilReadyCommand( device ));
        commands.push(new UninstallAppCommand( device.getName(), config.getPackage() ));
        commands.push(new InstallAndStartAppCommand( device, getAppPath(), config.getPackage(), listener));
    }

    private function setupNewProcess()
    {
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
}