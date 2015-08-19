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

import java.io.IOException;

import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.HttpClient;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.HttpResponse;
import org.apache.http.protocol.HTTP;
import android.util.Log;

public class TestHTTPLoggerPoster
{
	private static final String TAG = "duell";
	private static HttpClient client = new DefaultHttpClient();

	public static void post(String data, short port)
	{
		int tries = 3;
		while(tries-- > 0)
		{
			try {
				HttpPost post = new HttpPost("http://10.0.2.2:" + port + "/");
				post.setHeader("Accept", "application/json");
				post.setHeader("Content-type", "application/json");

				post.setEntity(new StringEntity(data));

				HttpResponse response = client.execute(post);
				response.getEntity().consumeContent();

				if (response.getStatusLine().getStatusCode() != 200)
				{
					Log.e(TAG, "HTTP ERROR:" + response.getStatusLine().getReasonPhrase());
					continue;
				}
			} catch(IOException except)
			{
				Log.e(TAG, "IOEXCEPTION:" + except);
				continue;
			}

			tries = 0;
		}
	}
}
