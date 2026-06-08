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
    static final String SEARCH_ENDPOINT = "https://garethpaul-app.appspot.com/api/search?q=";

    static String buildSearchUrl(String query) throws UnsupportedEncodingException {
        return SEARCH_ENDPOINT + URLEncoder.encode(String.valueOf(query), "UTF-8");
    }

    private static String queryFromParams(String... params) {
        if (params == null || params.length == 0 || params[0] == null) {
            return "";
        }

        return params[0];
    }

    private static JSONObject errorResult(String message) {
        JSONObject json = new JSONObject();
        try {
            json.put("text", message);
            json.put("image", "");
        } catch (JSONException e) {
            Log.e("network_request", "Unable to build error result", e);
        }

        return json;
    }

    @Override
    protected JSONObject doInBackground(String... params) {
        try {
            String query = queryFromParams(params);

            HttpParams httpParams = new BasicHttpParams();
            HttpConnectionParams.setConnectionTimeout(httpParams,
                    1000);
            HttpConnectionParams.setSoTimeout(httpParams, 1000);
            httpParams.setParameter("user", "1");

            // Instantiate an HttpClient
            HttpClient httpclient = new DefaultHttpClient(httpParams);
            String url = buildSearchUrl(query);
            Log.d("url", url);
            HttpGet httpget = new HttpGet(url);

            try {
                Log.v("network_request", "ok");
                //Log.i(getClass().getSimpleName(), "send  task - start");
                ResponseHandler<String> responseHandler = new BasicResponseHandler();

                String responseBody = httpclient.execute(httpget,
                        responseHandler);
                Log.v("network_request", responseBody);
                JSONObject json = new JSONObject(responseBody);
                Log.v("network_request", "got json");

                return json;


            } catch (ClientProtocolException e) {
                Log.e("network_request", "Search protocol error", e);
                return errorResult("Search request failed");
            } catch (IOException e) {
                Log.e("network_request", "Search IO error", e);
                return errorResult("Search request failed");
            } catch (JSONException e) {
                Log.e("network_request", "Search response parse error", e);
                return errorResult("Search request failed");
            }


        } catch (Throwable t) {
            Log.e("network_request", "Unexpected search request error", t);
            return errorResult("Search request failed");
        }
    }

    protected void onPostExecute(JSONObject feed) {

    }
}
