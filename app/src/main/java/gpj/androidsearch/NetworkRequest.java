package gpj.androidsearch;

import android.os.AsyncTask;
import android.util.Log;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.HttpResponseException;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.params.HttpClientParams;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.json.JSONException;
import org.json.JSONObject;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

public class NetworkRequest extends AsyncTask<String, Void, JSONObject> {
    static final String SEARCH_ENDPOINT = "https://garethpaul-app.appspot.com/api/search?q=";
    private static final int MAX_RESPONSE_BODY_BYTES = 64 * 1024;
    private volatile HttpGet activeHttpGet;

    public void cancelRequest() {
        HttpGet request = activeHttpGet;
        if (request != null) {
            request.abort();
        }
        cancel(true);
        HttpGet publishedAfterCancellation = activeHttpGet;
        if (publishedAfterCancellation != null && publishedAfterCancellation != request) {
            publishedAfterCancellation.abort();
        }
    }

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
            Log.e("network_request", "Unable to build error result");
        }

        return json;
    }

    private static ResponseHandler<String> boundedResponseHandler() {
        return new ResponseHandler<String>() {
            @Override
            public String handleResponse(HttpResponse response)
                    throws ClientProtocolException, IOException {
                StatusLine statusLine = response.getStatusLine();
                int statusCode = statusLine.getStatusCode();
                if (statusCode < 200 || statusCode >= 300) {
                    throw new HttpResponseException(statusCode,
                            statusLine.getReasonPhrase());
                }

                HttpEntity entity = response.getEntity();
                if (entity == null) {
                    return null;
                }
                Header contentType = entity.getContentType();
                if (contentType == null
                        || !ResponseMediaType.isJson(contentType.getValue())) {
                    throw new ClientProtocolException(
                            "Search response media type is not JSON");
                }

                InputStream content = entity.getContent();
                try {
                    return BoundedResponseBody.read(content,
                            entity.getContentLength(), MAX_RESPONSE_BODY_BYTES);
                } finally {
                    content.close();
                }
            }
        };
    }

    @Override
    protected JSONObject doInBackground(String... params) {
        try {
            String query = queryFromParams(params);

            HttpParams httpParams = new BasicHttpParams();
            HttpConnectionParams.setConnectionTimeout(httpParams,
                    1000);
            HttpConnectionParams.setSoTimeout(httpParams, 1000);
            HttpClientParams.setRedirecting(httpParams, false);
            httpParams.setParameter("user", "1");

            // Instantiate an HttpClient
            HttpClient httpclient = new DefaultHttpClient(httpParams);
            try {
                try {
                    String url = buildSearchUrl(query);
                    HttpGet httpget = new HttpGet(url);
                    activeHttpGet = httpget;
                    try {
                        if (isCancelled()) {
                            httpget.abort();
                            return null;
                        }
                        Log.v("network_request", "ok");
                        //Log.i(getClass().getSimpleName(), "send  task - start");
                        ResponseHandler<String> responseHandler = boundedResponseHandler();

                        String responseBody = httpclient.execute(httpget,
                                responseHandler);
                        JSONObject json = new JSONObject(responseBody);
                        Log.v("network_request", "got json");

                        return json;
                    } finally {
                        if (activeHttpGet == httpget) {
                            activeHttpGet = null;
                        }
                    }


                } catch (ClientProtocolException e) {
                    Log.e("network_request", "Search protocol error");
                    return errorResult("Search request failed");
                } catch (IOException e) {
                    Log.e("network_request", "Search IO error");
                    return errorResult("Search request failed");
                } catch (JSONException e) {
                    Log.e("network_request", "Search response parse error");
                    return errorResult("Search request failed");
                }
            } finally {
                httpclient.getConnectionManager().shutdown();
            }

        } catch (RuntimeException e) {
            Log.e("network_request", "Unexpected search request error");
            return errorResult("Search request failed");
        }
    }

    protected void onPostExecute(JSONObject feed) {

    }
}
