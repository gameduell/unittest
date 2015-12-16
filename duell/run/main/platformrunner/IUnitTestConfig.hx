package duell.run.main.platformrunner;

interface IUnitTestConfig
{
	function getPackage() : String;
	function getFile() : String;
	function winHeight() : String;
	function winWidth() : String;
}