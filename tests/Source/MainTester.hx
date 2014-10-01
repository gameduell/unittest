/*
 * Created by IntelliJ IDEA.
 * User: rcam
 * Date: 08/07/14
 * Time: 15:03
 */

import unittest.implementations.TestHTTPLogger;
import unittest.implementations.TestJUnitLogger;
import unittest.implementations.TestSimpleLogger;

import unittest.TestRunner;

import SimpleTest;
import AsyncTest;

import duell.DuellKit;

class MainTester
{
    private 

    static function main()
    {
        DuellKit.initialize(start);
    }

    static function start() : Void
    {
        var r = new TestRunner(testComplete);
        r.add(new SimpleTest());
        r.add(new AsyncTest());

        #if test
        r.addLogger(new TestHTTPLogger(new TestJUnitLogger()));
        #else
        r.addLogger(new TestSimpleLogger());
        #end

        r.run();
    }

    static function testComplete()
    {

    }

}