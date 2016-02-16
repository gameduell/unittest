package duell.run.main.platformrunner;

import duell.objects.DuellProcess;
import duell.objects.Server;
import duell.objects.Arguments;

import duell.helpers.ThreadHelper;
import duell.helpers.CommandHelper;
import duell.helpers.DuellConfigHelper;
import duell.helpers.LogHelper;

import sys.io.File;
import haxe.io.Path;
import haxe.Json;

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
        var serverTargetDirectory : String = Arguments.get('-path');
        
        server = new Server(serverTargetDirectory, -1, 3000);
        server.start();
    }

    private function runApp()
    {
        var electronFolder = Path.join([DuellConfigHelper.getDuellConfigFolderLocation(),
                                        "electron", "bin"]);
        var packageJsonContent = File.getContent(Path.join([Arguments.get('-path'), "package.json"]));
        var packageJson = Json.parse(packageJsonContent);

        var args = [Path.join([Arguments.get('-path'), packageJson.main])];

        if(Arguments.isSet("-verbose"))
        {
            args.push("--enable-logging");
        }

        nodeProcess = new DuellProcess(
                                        electronFolder,
                                        "electron",
                                        args,
                                        {
                                            logOnlyIfVerbose : true,
                                            systemCommand : false,
                                            errorMessage : "Running electron"
                                        });

        nodeProcess.blockUntilFinished();
    }

    private function quit()
    {
        if (server != null)
        {
            server.shutdown();
        }

        if(nodeProcess != null)
        {
            //LogHelper.info("=====================> send exit!!");
            nodeProcess.stdin.writeString("exit\n");
            nodeProcess.stdin.flush();
        }

        if (nodeProcess != null)
        {
            nodeProcess.kill();
        }
    }

    override public function closeTests()
    {
        super.closeTests();

        quit();
    }
}