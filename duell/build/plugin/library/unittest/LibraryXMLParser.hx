/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package duell.build.plugin.library.unittest;

import duell.build.objects.DuellProjectXML;
import duell.build.objects.Configuration;
import duell.build.plugin.library.unittest.LibraryConfiguration.KeyValueArray;
import duell.helpers.XMLHelper;
import haxe.xml.Fast;

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
        var testPort : Int = LibraryConfiguration.getData().TEST_PORT;
        var duellToolTestPort : Int = untyped Configuration.getData().TEST_PORT == null ?
            8181 : Configuration.getData().TEST_PORT;

        if (testPort != duellToolTestPort)
        {
            testPort = duellToolTestPort;
        }
        else if (element.has.value)
        {
            testPort = Std.parseInt(element.att.value);
        }

        LibraryConfiguration.getData().TEST_PORT = testPort;
    }
}
