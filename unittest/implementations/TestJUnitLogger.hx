/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 28/07/14
 * Time: 10:38
 */
package unittest.implementations;

import haxe.Log;
using StringTools;

class TestJUnitLogger implements unittest.TestLogger
{    
	private var outputBuffer : StringBuf;
    public function new ()
    {

    }

    public function setup() : Void
    {
    	print("<testsuites>" + "\n");
    }

    public function finish(result : TestResult, onFinishedCallback : TestLogger -> Void) :  Void
    {
    	print("</testsuites>" + "\n");

        onFinishedCallback(this);
    }

    private var oldTrace : Dynamic;
    public function logStartCase(currentCase : TestCase) : Void
    {
        oldTrace = haxe.Log.trace;
        haxe.Log.trace = function customTrace( v, ?p : haxe.PosInfos )
        {
        	outputBuffer.add(p.fileName+":"+p.lineNumber+": "+Std.string(v)+"\n");
        };

        var fieldNames = Type.getInstanceFields(Type.getClass(currentCase));

        var functionNames = fieldNames.filter( function (val) {
            var field = Reflect.field(currentCase, val);
            return StringTools.startsWith(val, "test") && Reflect.isFunction(field);
        });


    	print("<testsuite name=\"" + Type.getClass(currentCase) + "\" currentCasetests=\"" + functionNames.length + "\">" + "\n");
    }

    private var currentTest : TestStatus;
    public function logStartTest(currentTest : TestStatus) : Void
    {
        this.currentTest = currentTest;
    	outputBuffer = new StringBuf();
}

    public function logEndCase() : Void
    {
    	print("</testsuite>" + "\n");

        haxe.Log.trace = oldTrace;
    }

    public function logEndTest() : Void
    {
        switch(currentTest.testResultType)
        {
            case TestStatusTypeSuccessful:
				print("<testcase classname=\"" + currentTest.classname + "\" name=\"" + currentTest.method + "\" time=\"" + (currentTest.timeEnded - currentTest.timeStarted) + "\" />" + "\n");
            case TestStatusTypeSuccessfulShouldFail:
				print("<testcase classname=\"" + currentTest.classname + "\" name=\"" + currentTest.method + "\" time=\"" + (currentTest.timeEnded - currentTest.timeStarted) + "\" />" + "\n");
            case TestStatusTypeFailure:
				print("<testcase classname=\"" + currentTest.classname + "\" name=\"" + currentTest.method + "\" time=\"" + (currentTest.timeEnded - currentTest.timeStarted) + "\" >" + "\n");
				print("<failure type=\"" + "Failure" + "\">");
				if(currentTest.posInfos != null)
            		print(currentTest.posInfos.fileName+":" + currentTest.posInfos.lineNumber + ": " + currentTest.error + "\n");
            	else
            		print(currentTest.error);
				print("</failure>" + "\n");
				print("</testcase>" + "\n");
            case TestStatusTypeError:
				print("<testcase classname=\"" + currentTest.classname + "\" name=\"" + currentTest.method + "\" time=\"" + (currentTest.timeEnded - currentTest.timeStarted) + "\" >" + "\n");
				print("<error type=\"" + "Error" + "\">");
				if(currentTest.posInfos != null)
            		print(currentTest.posInfos.fileName+":" + currentTest.posInfos.lineNumber + ": " + currentTest.error + "\n");
            	else
            		print(currentTest.error);
				print("</error>" + "\n");
				print("</testcase>" + "\n");
            case TestStatusTypeWarningNoAssert:
				print("<testcase classname=\"" + currentTest.classname + "\" name=\"" + currentTest.method + "\" time=\"" + (currentTest.timeEnded - currentTest.timeStarted) + "\" >" + "\n");
				print("<failure type=\"" + "Failure" + "\">");
				if(currentTest.posInfos != null)
            		print(currentTest.posInfos.fileName+":" + currentTest.posInfos.lineNumber + ": " + currentTest.error + "\n");
            	else
            		print(currentTest.error);
				print("</failure>" + "\n");
				print("</testcase>" + "\n");
        }

    	outputBuffer = new StringBuf();
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