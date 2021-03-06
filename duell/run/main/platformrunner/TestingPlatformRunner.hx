package duell.run.main.platformrunner;

import duell.run.main.helpers.DefaultServerListenerHelper;

import duell.helpers.PathHelper;
import duell.helpers.LogHelper;
import duell.helpers.DuellLibHelper;
import duell.helpers.TestHelper;
import duell.helpers.AskHelper;
import duell.objects.Arguments;
import duell.objects.DuellLib;

import sys.FileSystem;
import haxe.io.Path;

class TestingPlatformRunner implements ITestingPlatformRunner
{
	private var unitTestLibPath : String;
	private var testResultFile : String;
	private var platform : String;
	private var dependedLibrary : String;
	private var listener : DefaultServerListenerHelper;

	public function new(platform : String)
	{
		this.platform = platform;

		unitTestLibPath = DuellLib.getDuellLib('unittest').getPath();

		dependedLibrary = 'duellbuild' + platform;
	}

	public function validateArguments() : Void {
		var path : String = "";
		if ( Arguments.isSet('-export') )
		{
			path = Arguments.get( '-export' );
		}
		else
		{
			path = Path.join([Sys.getCwd(), "unittests"]);
		}

		testResultFile = Path.join([path, resultFileName()]);
	}

	public function prepareTestRun() : Void
	{
		listener = new DefaultServerListenerHelper( testResultFile );

		checkDependedLibraryInstalled();
		clearTestResultFile();
	}

	private function clearTestResultFile()
	{
		// DELETE PREVIOUS TEST
		if (sys.FileSystem.exists(testResultFile))
		{
			sys.FileSystem.deleteFile(testResultFile);
		}

		// CREATE TARGET FOLDER
		PathHelper.mkdir(Path.directory(testResultFile));
	}

	private function checkDependedLibraryInstalled()
	{
		var lib = DuellLib.getDuellLib( dependedLibrary );

		if(!DuellLibHelper.isInstalled( lib.name ))
		{
			var answer = AskHelper.askYesOrNo("The dependend library '" + lib.name + "' for running the unittests is currently not installed. Would you like to try to install it?");
			if(answer)
			{
				DuellLibHelper.install( lib.name );
			}
			else
			{
				LogHelper.exitWithFormattedError("Dependend library '" + lib.name + "' not existing.");
			}
		}
	}

	private function runListener()
	{
		listener.runListener();
	}

	public function runTests() : Void 
	{	
	}

	public function closeTests() : Void
	{
	}

	private function getAppPath() : String
	{
		return Arguments.get("-path");
	}


	private function resultFileName() : String
	{
		return 'test_result_' + platform + '.xml';
	}
}