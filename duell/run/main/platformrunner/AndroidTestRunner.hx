package duell.run.main.platformrunner;

import duell.objects.DuellProcess;
import duell.run.helpers.Emulator;


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
	}

	override public function closeTests() : Void
	{
		shutdownEmulator();
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