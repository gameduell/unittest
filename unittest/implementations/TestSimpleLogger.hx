/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 09/07/14
 * Time: 10:38
 */
package unittest.implementations;

import haxe.Log;
using StringTools;

class TestSimpleLogger implements unittest.TestLogger
{
    public function new ()
    {

    }

    public function setup() : Void
    {

    }

    public function finish(result : TestResult) :  Void
    {
        print(result.toString());
    }

    private var oldTrace : Dynamic;
    public function logStartCase(currentCase : TestCase) : Void
    {
        oldTrace = haxe.Log.trace;
        haxe.Log.trace = function customTrace( v, ?p : haxe.PosInfos )
        {
            print(p.fileName+":"+p.lineNumber+": "+Std.string(v)+"\n");
        };

        print( "Class: " + Type.getClassName(Type.getClass(currentCase)) + " ");
    }

    private var currentTest : TestStatus;
    public function logStartTest(currentTest : TestStatus) : Void
    {
        this.currentTest = currentTest;
    }

    public function logEndCase() : Void
    {
        print("\n");

        haxe.Log.trace = oldTrace;
    }

    public function logEndTest() : Void
    {
        switch(currentTest.testResultType)
        {
            case TestStatusTypeSuccessful:
                print(".");
            case TestStatusTypeSuccessfulShouldFail:
                print(".");
            case TestStatusTypeFailure:
                print("F");
            case TestStatusTypeError:
                print("E");
            case TestStatusTypeWarningNoAssert:
                print("W");
        }

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