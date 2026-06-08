package gpj.androidsearch;

import android.os.AsyncTask;
import android.util.Log;

import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.json.JSONException;
import org.json.JSONObject;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

public class NetworkRequest extends AsyncTask<String, Void, JSONObject> {
    private static final String TAG = "network_request";
    static final String SEARCH_ENDPOINT = "https://garethpaul-app.appspot.com/api/search?q=";

    static String buildSearchUrl(String query) throws UnsupportedEncodingException {
        return SEARCH_ENDPOINT + URLEncoder.encode(String.valueOf(query), "UTF-8");
    }

    @Override
    protected JSONObject doInBackground(String... params) {
        if (params == null || params.length == 0 || params[0] == null) {
            Log.e(TAG, "Search query missing.");
            return null;
        }

        String query;
        query = params[0];

        HttpParams httpParams = new BasicHttpParams();
        HttpConnectionParams.setConnectionTimeout(httpParams,
                1000);
        HttpConnectionParams.setSoTimeout(httpParams, 1000);
        //
        HttpParams p = new BasicHttpParams();
        // p.setParameter("name", pvo.getName());
        p.setParameter("user", "1");

        // Instantiate an HttpClient
        HttpClient httpclient = new DefaultHttpClient(p);
        String url;
        try {
            url = buildSearchUrl(query);
        } catch (UnsupportedEncodingException e) {
            Log.e(TAG, "Could not encode search query.", e);
            return null;
        }
        Log.d("url", url);
        HttpGet httpget = new HttpGet(url);

        try {
            Log.v(TAG, "ok");
            //Log.i(getClass().getSimpleName(), "send  task - start");
            ResponseHandler<String> responseHandler = new BasicResponseHandler();

            String responseBody = httpclient.execute(httpget,
                    responseHandler);
            Log.v(TAG, responseBody);
            JSONObject json = new JSONObject(responseBody);
            Log.v(TAG, "got json");

            return json;
        } catch (ClientProtocolException e) {
            Log.e(TAG, "Search request protocol failure.", e);
        } catch (IOException e) {
            Log.e(TAG, "Search request I/O failure.", e);
        } catch (JSONException e) {
            Log.e(TAG, "Search response JSON parse failure.", e);
        }
        return null;
    }

    protected void onPostExecute(JSONObject feed) {

    }
}
