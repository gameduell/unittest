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

package duell.run.main.helpers;

import duell.run.main.platformrunner.IUnitTestConfig;

import duell.defines.DuellDefines;

import duell.helpers.PathHelper;
import duell.helpers.LogHelper;
import duell.helpers.XMLHelper;

import sys.io.File;
import sys.FileSystem;

import haxe.Template;
import haxe.io.Path;
import haxe.xml.Fast;

typedef AppConfig = {
	title : String,
	file : String,
	classpath : String,
	version	: String,
	company : String,
	buildNumber : String
}

class UnitTestConfig implements IUnitTestConfig
{

	private static var cache : IUnitTestConfig;

	public static function getConfig() : IUnitTestConfig
	{
		if(cache == null)
		{
			cache = new UnitTestConfig();
			return cache;
		}

		return cache;
	}

	private var appConfig : AppConfig;

	private function new() : Void
	{
	}

	public function parse()
	{
		if (!FileSystem.exists(DuellDefines.PROJECT_CONFIG_FILENAME))
		{
			throw 'Project config file not found. There should be a ${DuellDefines.PROJECT_CONFIG_FILENAME} here';
		}

		parseFile(Path.join([Sys.getCwd(), DuellDefines.PROJECT_CONFIG_FILENAME]));
	}

	private function parseFile(file : String)
	{
		if (!PathHelper.isPathRooted(file))
			throw "internal error, parseFile should only receive rooted paths.";

		var stringContent = File.getContent(file);
		var currentXML = new Fast(Xml.parse(stringContent).firstElement());

		for (element in currentXML.elements)
		{
			switch (element.name)
			{
				case 'app':
					parseAppElement(element);

				case 'output':
					parseOutputElement(element);
			}
		}
	}

	private function parseAppElement(element : Fast)
	{
		if(appConfig == null )
			appConfig = {title : '',file : '', classpath : '', version : '', company : '', buildNumber : ''};

		if (element.has.title)
		{
			appConfig.title = element.att.title;
		}

		if (element.has.file)
		{
			appConfig.file = element.att.file;

			var checkFile = ~/^([0-9]|[A-Z]|[a-z]|_)+$/;
			if (!checkFile.match(appConfig.file))
				throw "app title can only have letters, numbers, and underscores, no spaces or other characters";
		}

		if (element.has.resolve("package")) ///package is a keyword
		{
			appConfig.classpath = element.att.resolve("package");

			checkForInvalidCharacterInPackageName(appConfig.classpath);
		}

		if (element.has.company)
		{
			appConfig.company = element.att.company;
		}

		if (element.has.version)
		{
			appConfig.version = element.att.version;
		}

		if (element.has.buildNumber)
		{
			appConfig.buildNumber = element.att.buildNumber;
		}
	}

	private function parseOutputElement(element : Fast)
	{
		if (element.has.path)
		{
			// Configuration.getData().OUTPUT = resolvePath(element.att.path);
		}
	}

	/// ---------------
	/// HELPERS
	/// ---------------
	// private function resolvePath(path : String) : String
	// {
	// 	path = PathHelper.unescape(path);

	// 	if (PathHelper.isPathRooted(path))
	// 		return path;

	// 	path = Path.join([currentXMLPath[currentXMLPath.length - 1], path]);
	// 	return path;
	// }

	private function checkForInvalidCharacterInPackageName(packageName: String): Void
    {
		var validNonAlphaNumericCharacters: Array<Int> = ['.'.code];
		for (i in 0...packageName.length)
		{
			var char: String = packageName.charAt(i);
			var charCode: Int = char.toLowerCase().charCodeAt(0);

			if (charCode >= 48 && charCode <= 57) /// number
				continue;

			if (charCode >= 97 && charCode <= 122) /// lower case letter
				continue;

			if (validNonAlphaNumericCharacters.indexOf(charCode) != -1)
				continue;

            throw '[ERROR] Invalid character \'$char\' found at pos $i in package name \'$packageName\'';
		}
    }

    public function getPackage() : String
    {
    	return appConfig != null ? appConfig.classpath : '';
    }

	public function getFile() : String
	{
		return appConfig != null ? appConfig.file : '';
	}
}
