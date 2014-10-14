/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 07/07/14
 * Time: 12:10
 */
package unittest.implementations;

import haxe.ds.StringMap;
import unittest.TestResult;
import unittest.TestCase;
import unittest.TestStatus;
import haxe.Http;
import unittest.Utils;
import asyncrunner.Task;

import de.polygonal.ds.LinkedQueue;
import msignal.Signal.Signal1;

#if android
import hxjni.JNI;
#end


class TestHTTPLogger implements unittest.TestLogger
{
    private var logger : TestLogger;
    private var url : String;

    private var httpMessageQueue : SequentialTaskQueue = new SequentialTaskQueue();

#if android
    static public var DEFAULT_URL = "http://10.0.2.2:8181";
#else
    static public var DEFAULT_URL = "http://localhost:8181";
#end

    public function new(testLogger : TestLogger, url : String = null) : Void
    {
        logger = testLogger;

        if(logger == null)
        {
            throw "Null logger passed to TestHTTPLogger";
        }

        if(url == null)
            this.url = DEFAULT_URL;
        else
            this.url = url;

        logger.setLogMessageHandler(loggedMessageInterception);
    }

    public function loggedMessageInterception(message : Dynamic) : Void
    {
        postTestMessage(message);
        print(message);
    }

    public function setup() : Void
    {
        logger.setup();
    }

    private var onFinishedCallback : TestLogger -> Void;
    public function finish(result : TestResult, onFinishedCallback : TestLogger -> Void) :  Void
    {
        this.onFinishedCallback = onFinishedCallback;
        logger.finish(result, postTestEnded);
    }

    private function postTestEnded(testLogger : TestLogger)
    {
        httpMessageQueue.queueIsEmpty.add(function(taskQueue : SequentialTaskQueue) onFinishedCallback(this));
        var httpRequestTask = new HttpPostTask(url, "===END===");
        httpMessageQueue.add(httpRequestTask);
    }

    private function postTestMessage(testMessage : String)
    {
        var httpRequestTask = new HttpPostTask(url, testMessage);
        httpMessageQueue.add(httpRequestTask);
    }

    public function logStartCase(currentCase : TestCase) : Void
    {
        logger.logStartCase(currentCase);
    }

    public function logStartTest(currentTest : TestStatus) : Void
    {
        logger.logStartTest(currentTest);
    }

    public function logEndCase() : Void
    {
        logger.logEndCase();
    }

    public function logEndTest() : Void
    {
        logger.logEndTest();
    }

    private var logMessageHandler : Dynamic -> Void = null;
    public function setLogMessageHandler(logMessageHandler : Dynamic -> Void)
    {
        this.logMessageHandler = logMessageHandler;
    }

    public dynamic function print( v : Dynamic ) untyped
    {
        if(logMessageHandler != null)
        {
            logMessageHandler(v);
            return;
        }

        Utils.print(v);
    }
}

class SequentialTaskQueue
{
    var queue : LinkedQueue<Task> = new LinkedQueue<Task>();

    public var queueIsEmpty : Signal1<SequentialTaskQueue> = new Signal1(); 
    public function new()
    {

    }

    public function add(task : Task)
    {
        task.onFinish.add(taskFinished);
        if (queue.size() != 0)
        {
            queue.back().onFinish.add(function(t : Task) task.execute());
            queue.enqueue(task);
        }
        else
        {
            queue.enqueue(task);
            task.execute();
        }
    }

    public function taskFinished(task : Task)
    {
        queue.dequeue();

        if (queue.size() == 0)
        {
            queueIsEmpty.dispatch(this);
        }
    }
}

class HttpPostTask extends Task
{
    public var urlRequest : URLRequest;  
    public function new(url : String, data : String)
    {
        super();

        urlRequest = new URLRequest(url);

        urlRequest.onData = function onData(data:String):Void
        { 
            finishExecution();
        };
        urlRequest.onError = function onError(msg:String):Void
        {
            finishExecution();
        };
        urlRequest.data = data;
    }

    override function execute()
    {
        urlRequest.send();
    }
}

// TODO This is a simple wrapper shamefully stolen from munit. Should get a proper one from our eventual network lib.

class URLRequest
{

#if (!android)
    public var onData:Dynamic -> Void;
    public var onError:Dynamic ->Void;
    public var data:Dynamic;

    var url:String;
    var headers:StringMap<String>;

    #if (js || neko || cpp)
		public var client:Http;
	#elseif flash9
		public var client:flash.net.URLRequest;
	#elseif flash
		public var client:flash.LoadVars;
	#end


    public function new(url:String)
    {
        this.url = url;
        createClient(url);
        setHeader("Content-Type", "text/plain");
    }

    function createClient(url:String)
    {
        #if (js || neko || cpp)
			client = new Http(url);
		#elseif flash9
			client = new flash.net.URLRequest(url);
		#elseif flash
			client = new flash.LoadVars();
		#end
    }

    public function setHeader(name:String, value:String)
    {
        #if (js || neko || cpp)
			client.setHeader(name, value);
		#elseif flash9
			client.requestHeaders.push(new flash.net.URLRequestHeader(name, value));
		#elseif flash
			client.addRequestHeader(name, value);
		#end
    }

    public function send()
    {
        #if (js || neko || cpp)
			client.onData = onData;
			client.onError = onError;
			#if js
				client.setPostData(data);
			#else
				client.setParameter("data", data);
			#end
			client.request(true);
		#elseif flash9
			client.data = data;
			client.method = "POST";
			var loader = new flash.net.URLLoader();
			loader.addEventListener(flash.events.Event.COMPLETE, internalOnData);
			loader.addEventListener(flash.events.IOErrorEvent.IO_ERROR, internalOnError);

			loader.load(client);
		#elseif flash
			var result = new flash.LoadVars();
			result.onData = internalOnData;

			client.data = data;
			client.sendAndLoad(url, result, "POST");
		#end
    }

    #if flash9
    function internalOnData(event:flash.events.Event)
    {
        onData(event.target.data);
    }

    function internalOnError(event:flash.events.Event)
    {
        onError("Invalid Server Response.");
    }
	#elseif flash
    function internalOnData(value:String)
    {
        if (value == null)
            onError("Invalid Server Response.");
        else
            onData(value);
    }
	#end

#else

    private var j_post = JNI.createStaticMethod("org/haxe/duell/unittest/TestHTTPLoggerPoster", "post", "(Ljava/lang/String;)V");

    public var onData:Dynamic -> Void;
    public var onError:Dynamic ->Void;
    public var data:Dynamic;

    var url:String;
    var headers:StringMap<String>;

    public function new(url:String)
    {
        this.url = url;
    }

    function createClient(url:String)
    {

    }

    public function setHeader(name:String, value:String)
    {

    }

    public function send()
    {
        j_post("" + data);
        onData("OK");
    }

#end
}