## Description

This library provides a Unit Test API that is basically an extension to the haxe.unit std tests. It adds in async tests and a retry functionality. In order to have async tests, the library depends on the runloop library being setup where the tests run, and also that a onError signal be passed in when the TestRunner is initialized. This last dependency is needed so that the test runner can gracefully fail a test in case it fails asynchronously.

## Usage:

Check the tests for more information on how to use it.
