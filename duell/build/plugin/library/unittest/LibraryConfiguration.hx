package duell.build.plugin.library.unittest;

typedef KeyValueArray = Array<{NAME : String, VALUE : String}>;

typedef LibraryConfigurationData = {
    TEST_PORT : Int,
}

class LibraryConfiguration
{
    public static var _configuration : LibraryConfigurationData = null;
    private static var _parsingDefines : Array<String> = ["unittest"];
    public static function getData() : LibraryConfigurationData
    {
        if (_configuration == null)
            initConfig();
        return _configuration;
    }

    public static function getConfigParsingDefines() : Array<String>
    {
        return _parsingDefines;
    }

    public static function addParsingDefine(str : String)
    {
        _parsingDefines.push(str);
    }

    private static function initConfig()
    {
        _configuration =
        {
            TEST_PORT : 8181
        };
    }

}
