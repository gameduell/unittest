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


class TestHTTPLogger implements unittest.TestLogger
{
    private var logger : TestLogger;
    private var request : URLRequest;
    private var url : String;

#if android
    static public var DEFAULT_URL = "http://localhost:8181";
#else
    static public var DEFAULT_URL = "http://10.0.2.2:8181";
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

        messageBuffer = "";
    }

    private var messageBuffer : String;
    public function loggedMessageInterception(message : Dynamic) : Void
    {
        messageBuffer += message;
        print(message);
    }

    public function setup() : Void
    {
        logger.setup();
    }

    private var onFinishedCallback : TestLogger -> Void;
    public function finish(result : TestResult, onFinishedCallback : TestLogger -> Void) :  Void
    {
        logger.finish(result, innerLoggerFinished);
        this.onFinishedCallback = onFinishedCallback;
    }

    private function innerLoggerFinished(testLogger : TestLogger)
    {
        print("\n\nTestHTTPLogger: posting log to "  + url + ":\n");

        request = new URLRequest(url);
        request.onData = onData;
        request.onError = onError;
        request.data = messageBuffer;

        request.send();
    }

    private function onData(data:String):Void
    {
        print("TestHTTPLogger: response:\n"  + data + "\n");
        onFinishedCallback(this);
    }

    private function onError(msg:String):Void
    {
        print("TestHTTPLogger: error:\n"  + msg + "\n");
        onFinishedCallback(this);
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

        #if flash9
			if( tf == null ) {
				tf = new flash.text.TextField();
				tf.selectable = false;
				tf.width = flash.Lib.current.stage.stageWidth;
				tf.autoSize = flash.text.TextFieldAutoSize.LEFT;
				flash.Lib.current.addChild(tf);
			}
			tf.appendText(v);
		#elseif flash
			var root = flash.Lib.current;
			if( tf == null ) {
				root.createTextField("__tf",1048500,0,0,flash.Stage.width,flash.Stage.height+30);
				tf = root.__tf;
				tf.selectable = false;
				tf.wordWrap = true;
			}
			var s = flash.Boot.__string_rec(v,"");
			tf.text += s;
			while( tf.textHeight > flash.Stage.height ) {
				var lines = tf.text.split("\r");
				lines.shift();
				tf.text = lines.join("\n");
			}
		#elseif neko
			__dollar__print(v);
		#elseif php
			php.Lib.print(v);
		#elseif cpp
			cpp.Lib.print(v);
		#elseif js
			var msg = js.Boot.__string_rec(v,"");
			var d;
            if( __js__("typeof")(document) != "undefined"
                    && (d = document.getElementById("haxe:trace")) != null ) {
                msg = msg.split("\n").join("<br/>");
                d.innerHTML += StringTools.htmlEscape(msg)+"<br/>";
            }
			else if (  __js__("typeof process") != "undefined"
					&& __js__("process").stdout != null
					&& __js__("process").stdout.write != null)
				__js__("process").stdout.write(msg); // node
			else if (  __js__("typeof console") != "undefined"
					&& __js__("console").log != null )
				__js__("console").log(msg); // document-less js (which may include a line break)

		#elseif cs
			cs.system.Console.Write(v);
		#elseif java
			var str:String = v;
			untyped __java__("java.lang.System.out.print(str)");
		#end
    }



    #if flash9
        static var tf : flash.text.TextField = null;
    #elseif flash
        static var tf : flash.TextField = null;
    #end

}

// TODO This is a simple wrapper shamefully stolen from munit. Should get a proper one from our eventual network lib.

class URLRequest
{
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
}