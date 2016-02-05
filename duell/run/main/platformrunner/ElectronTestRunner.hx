package duell.run.main.platformrunner;

import duell.objects.DuellProcess;
import duell.objects.Server;
import duell.objects.Arguments;

import duell.helpers.ThreadHelper;
import duell.helpers.CommandHelper;
import duell.helpers.DuellConfigHelper;
import duell.helpers.LogHelper;

import haxe.io.Path;

class ElectronTestRunner extends TestingPlatformRunner
{

    private static inline var DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP = 2;

    private var nodeProcess : DuellProcess;
    private var server : Server;

    public function new()
    {
        super('electron');
    }

    override public function runTests()
    {
        super.runTests();
        LogHelper.info("run tests...");
        startHTTPServer();

        var targetTime = haxe.Timer.stamp() + DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP;
        ThreadHelper.runInAThread(function()
        {
            Sys.sleep(DELAY_BETWEEN_PYTHON_LISTENER_AND_RUNNING_THE_APP);

            runApp();
        });

        try
        {
            runListener();
        }
        catch(e : Dynamic)
        {
            quit();

            throw e;
        }
    }

    private function startHTTPServer()
    {
        LogHelper.info("start http server...");
        var serverTargetDirectory : String = Arguments.get('-path');
        
        server = new Server(serverTargetDirectory, -1, 3000);
        server.start();
    }

    private function runApp()
    {
        LogHelper.info("run app...");
        var electronFolder = Path.join([DuellConfigHelper.getDuellConfigFolderLocation(),
                                        "electron", "bin"]);
        nodeProcess = new DuellProcess(
                                        electronFolder,
                                        "electron",
                                        [Path.join([Arguments.get('-path'), "bootstrap.js"])],
                                        {
                                            logOnlyIfVerbose : true,
                                            systemCommand : false,
                                            errorMessage : "Running electron"
                                        });

        nodeProcess.blockUntilFinished();
    }

    private function quit()
    {
        LogHelper.info("quit...");
        if (server != null)
        {
            server.shutdown();
        }
        
        if (nodeProcess != null)
        {
            nodeProcess.kill();
        }
    }

    override public function closeTests()
    {
        LogHelper.info("close tests...");
        super.closeTests();

        quit();
    }
}