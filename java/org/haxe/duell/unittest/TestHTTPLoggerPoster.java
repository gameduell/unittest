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

package org.haxe.duell.unittest;

import java.io.DataOutputStream;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

import android.util.Log;

public class TestHTTPLoggerPoster
{
	private static final String TAG = "duell";

	public static void post(String data, short port)
	{
		int tries = 10;
		while(tries-- > 0)
		{
			try {
				/// PREPARE OBJECTS
				URL url = new URL("http://localhost:" + port + "/");

				HttpURLConnection connection = (HttpURLConnection) url.openConnection();

				connection.setRequestMethod("POST");
				connection.setRequestProperty("Accept", "application/json");
				connection.setRequestProperty("Content-type", "application/json");

				connection.setDoOutput(true);

				DataOutputStream wr = new DataOutputStream(connection.getOutputStream());
				wr.write(data.getBytes());
				wr.flush();
				wr.close();

				int statusCode = connection.getResponseCode();

				if (statusCode != HttpURLConnection.HTTP_OK) {

					Log.e(TAG, "HTTP ERROR:" + statusCode);
					android.os.SystemClock.sleep(500);
					continue;

				}

			} catch(IOException except)
			{
				Log.e(TAG, "IOEXCEPTION:" + except);
				android.os.SystemClock.sleep(500);
				continue;
			}

			tries = 0;
		}
	}
}
