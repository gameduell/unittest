package org.haxe.duell.unittest;

import java.io.IOException;

import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.HttpClient;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.HttpResponse;
import android.util.Log;

public class TestHTTPLoggerPoster 
{
	private static final String TAG = "duell";

	public static void post(String data) throws IOException
	{
		HttpClient client = new DefaultHttpClient();
		HttpPost post = new HttpPost("http://10.0.2.2:8181/");

		post.setEntity(new StringEntity(data));

		HttpResponse response = client.execute(post);

		if (response.getStatusLine().getStatusCode() != 200)
		{
			Log.e(TAG, "HTTP ERROR:" + response.getStatusLine().getReasonPhrase());
		}
	}
}