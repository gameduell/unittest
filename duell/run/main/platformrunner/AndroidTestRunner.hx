package duell.run.main.platformrunner;

import duell.objects.Arguments;
import duell.helpers.LogHelper;
import duell.run.main.helpers.Device;
import duell.run.main.helpers.FetchLogcatHelper;
import duell.run.main.emulator.Emulator;
import duell.run.main.emulator.commands.IEmulatorCommand;
import duell.run.main.emulator.commands.CreateEmulatorCommand;
import duell.run.main.emulator.commands.KillServerCommand;
import duell.run.main.emulator.commands.StartServerCommand;
import duell.run.main.emulator.commands.WaitUntilReadyCommand;
import duell.run.main.emulator.commands.UninstallAppCommand;
import duell.run.main.emulator.commands.InstallAppCommand;
import duell.run.main.emulator.commands.StartAppCommand;
import duell.run.main.emulator.commands.ReverseCommunicationCommand;
import duell.run.main.emulator.commands.RemoveReversedCommunicationCommand;

class AndroidTestRunner extends TestingPlatformRunner
{
    private static inline var NEEDED_ANDROID_VERSION_REVERSE_COMMUNICTION = 5;
    private static inline var DEFAULT_ARMV7_EMULATOR = "duellarmv7";
    private static inline var DEFAULT_X86_EMULATOR = "duellx86";

    private var emulator : Emulator;
    private var emulatorName : String = null;
    private var emulatorArch : EmulatorArchitecture = null;
    private var commands : Array<IEmulatorCommand>;
    private var package_path : String; 

    public function new()
    {
        super("android");
    }

    override public function validateArguments() : Void {
        super.validateArguments();

        if( !Arguments.isSet("-package") )
        {
            LogHelper.exitWithFormattedError("To run unittests on Android the application package is needed, e.g. '-package de.gameduell.unittestApplication'");
        }

        package_path = Arguments.get("-package");
    }

    override public function prepareTestRun() : Void
    {
        super.prepareTestRun();

        setArchitecture();
        initializeEmulator();

        if(Arguments.isSet('-devicename'))
        {
            checkDeviceUsage();
        }
        else
        {
            checkReuseEmulator();
        }
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

    private function checkDeviceUsage()
    {
        var deviceName = Arguments.get('-devicename');
        var chosenDevice = emulator.getDeviceByName( deviceName );
        if(chosenDevice == null || !chosenDevice.isOnline() )
        {
            LogHelper.exitWithFormattedError("No device with name '" + deviceName + "' found or the device is not online! Device: " + chosenDevice);
        }

        if( emulator.isEmulatorDevice( chosenDevice.name ) )
        {
            //check if architecture is correct
            if( chosenDevice.arch != emulatorArch )
            {
                LogHelper.exitWithFormattedError("Selected emulator device architecture doesn't match. Set device architecture by using '-x86' or don't set anything to use the default one (ARM).");
            }

            setupReuseProcess( chosenDevice );
        }
        else
        {
            setupRealDeviceProcess( chosenDevice );
        }
    }

    private function setupRealDeviceProcess( realDevice : Device )
    {
        emulator.useDevice( realDevice );

        LogHelper.info("", "Using the real device: " + realDevice);
        var helper = getLogCatHelper( realDevice );

        //create real device commands
        commands = new Array<IEmulatorCommand>();
        commands.push(new UninstallAppCommand( realDevice.name, package_path ));
        commands.push(new InstallAppCommand( realDevice, getAppPath()));
        
        if( helper == null)
            commands.push(new ReverseCommunicationCommand( realDevice ));

        commands.push(new StartAppCommand( realDevice, package_path, listener, helper ));

        if( helper == null )
            commands.push(new RemoveReversedCommunicationCommand( realDevice ));
    }

    private function checkReuseEmulator()
    {
        var runningDevice = emulator.getRunningEmulatorDevice( emulatorArch );
        if ( runningDevice != null )
        {
            setupReuseProcess( runningDevice );
        }
        else
        {
            setupNewProcess();
        }
    }

    /**
     * funciton setupReuseProcess
     * This function reuses an existing and running emulator device. It supsects
     * that the android version is higher or equal NEEDED_ANDROID_VERSION_REVERSE_COMMUNICTION.
     *
     * @param device Device Device which should be re-used
    **/
    private function setupReuseProcess( device : Device )
    {   
        emulator.useDevice( device );

        LogHelper.info("", "Reuse the existing device: " + device);

        //create emulator commands
        commands = new Array<IEmulatorCommand>();
        commands.push(new WaitUntilReadyCommand( device ));
        commands.push(new UninstallAppCommand( device.name, package_path ));
        commands.push(new InstallAppCommand( device, getAppPath()));
        commands.push(new StartAppCommand( device, package_path, listener ));
    }

    /**
     * funciton setupNewProcess
     * This function creates a new emulator device and suspects that the 
     * android version is higher or equal NEEDED_ANDROID_VERSION_REVERSE_COMMUNICTION.
     * If this changes, check if you have to use a LogcatHelper to get the output regarding
     * a not working HTTP reverse communication.
     *
     * @param device Device Device which should be re-used
    **/
    private function setupNewProcess()
    {
        var device = emulator.createEmulatorDevice( emulatorArch );
        emulator.useDevice( device );
        
        LogHelper.info("", "Created new emulator device: " + device);

        //create emulator commands
        commands = new Array<IEmulatorCommand>();
        commands.push(new KillServerCommand());
        commands.push(new StartServerCommand());
        commands.push(new CreateEmulatorCommand( emulatorName, device ));
        commands.push(new WaitUntilReadyCommand( device ));
        commands.push(new UninstallAppCommand( device.name, package_path ));
        commands.push(new InstallAppCommand( device, getAppPath()));
        commands.push(new ReverseCommunicationCommand( device ));
        commands.push(new StartAppCommand( device, package_path, listener ));
    }

    private function getLogCatHelper( device:Device ) : FetchLogcatHelper
    {
        return isReverseCommunicationAvailable( device ) ? null : new FetchLogcatHelper( device );
    }

    private function isReverseCommunicationAvailable( device:Device ) : Bool
    {
        return device.getMajorVersion() >= NEEDED_ANDROID_VERSION_REVERSE_COMMUNICTION ? true : false;
    }
}