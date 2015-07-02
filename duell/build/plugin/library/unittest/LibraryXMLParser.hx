package duell.build.plugin.library.unittest;

import duell.build.plugin.library.unittest.LibraryConfiguration.KeyValueArray;

class LibraryXMLParser
{
    public static function parse(xml : Fast) : Void
    {
        Configuration.getData().LIBRARY.UNITTEST = LibraryConfiguration.getData();

        for (element in xml.elements)
        {
            if (!XMLHelper.isValidElement(element, DuellProjectXML.getConfig().parsingConditions))
                continue;

            switch(element.name)
            {
                case 'test-port':
                    parseTestPort(element);

            }
        }
    }

    private static function parseTestPort(element : Fast)
    {
        if (element.has.value)
        {
            LibraryConfiguration.getData().TEST_PORT = Std.parseInt(element.value);
        }
    }
}
