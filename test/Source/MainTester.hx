/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 08/07/14
 * Time: 15:03
 */


import unittest.implementations.TestHTTPLogger;
import unittest.implementations.TestSimpleLogger;
import platform.AppMain;

import unittest.TestRunner;

import SimpleTest;
import AsyncTest;


class MainTester extends AppMain
{
    private var r : TestRunner;
    override function start() : Void
    {
        r = new TestRunner(testComplete);
        r.add(new SimpleTest());
        r.add(new AsyncTest());

        r.addLogger(new TestHTTPLogger(new TestSimpleLogger()));

        r.run();
    }

    public function testComplete()
    {
        
    }

}