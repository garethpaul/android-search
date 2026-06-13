package gpj.androidsearch;

import android.app.ActionBar;
import android.app.Activity;
import android.app.SearchManager;
import android.app.SearchableInfo;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.SearchView;
import android.widget.TextView;

import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

import javax.net.ssl.HttpsURLConnection;

public class MainActivity extends Activity {

    private static final String LOG_TAG = "android_search";
    private static final int IMAGE_DOWNLOAD_TIMEOUT_MILLIS = 1000;

    private TextView textView;
    private NetworkRequest activeSearchRequest;
    private DownloadImageTask activeImageRequest;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        textView = (TextView) findViewById(R.id.textView);
        configureActionBar();
        handleIntent(getIntent());
    }

    private void configureActionBar() {
        ActionBar actionBar = getActionBar();
        if (actionBar == null) {
            return;
        }

        actionBar.setDisplayHomeAsUpEnabled(false);
        actionBar.setDisplayShowHomeEnabled(true);
        actionBar.setIcon(R.drawable.search);
    }

    @Override
    protected void onNewIntent(Intent intent) {

        handleIntent(intent);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        if (menu == null) {
            Log.w(LOG_TAG, "Search options menu is unavailable");
            return false;
        }

        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_main, menu);

        // Associate searchable configuration with the SearchView
        SearchManager searchManager =
                (SearchManager) getSystemService(Context.SEARCH_SERVICE);
        MenuItem searchItem = menu.findItem(R.id.action_search);
        if (searchItem == null) {
            Log.w(LOG_TAG, "Search menu item is missing");
            return true;
        }

        if (searchManager == null) {
            Log.w(LOG_TAG, "Search UI is unavailable");
            return true;
        }

        View actionView = searchItem.getActionView();
        if (!(actionView instanceof SearchView)) {
            Log.w(LOG_TAG, "Search action view is unavailable");
            return true;
        }

        SearchView searchView = (SearchView) actionView;
        SearchableInfo searchableInfo = searchManager.getSearchableInfo(getComponentName());
        if (searchableInfo == null) {
            Log.w(LOG_TAG, "Searchable configuration is unavailable");
            return true;
        }

        searchView.setSearchableInfo(searchableInfo);

        int searchImgId = getResources().getIdentifier("android:id/search_button", null, null);
        ImageView v = (ImageView) searchView.findViewById(searchImgId);
        if (v != null) {
            v.setImageResource(R.drawable.cross);
        }
        
        return true;
    }

    private void handleIntent(Intent intent) {
        if (intent == null) {
            Log.w(LOG_TAG, "Search intent is unavailable");
            return;
        }

        if (!Intent.ACTION_SEARCH.equals(intent.getAction())) {
            return;
        }

        if (textView == null) {
            Log.w(LOG_TAG, "Search result text view is unavailable");
            return;
        }

        String query = intent.getStringExtra(SearchManager.QUERY);
        cancelActiveRequests();
        clearResultImage();
        if (query == null || query.trim().length() == 0) {
            textView.setText(R.string.search_request_failed);
            return;
        }

        activeSearchRequest = new NetworkRequest() {
            @Override
            protected void onPostExecute(JSONObject json) {
                if (activeSearchRequest != this || isFinishing() || isDestroyed()) {
                    return;
                }

                activeSearchRequest = null;
                displaySearchResult(json);
            }
        };
        activeSearchRequest.execute(query.trim());
    }

    private void displaySearchResult(JSONObject json) {
        if (textView == null) {
            return;
        }

        cancelActiveImageRequest();
        ImageView imageView = (ImageView) findViewById(R.id.imageView);

        if (json == null) {
            textView.setText(R.string.search_request_failed);
            return;
        }

        String textInfo = json.optString("text", getString(R.string.search_request_failed));
        textView.setText(textInfo);

        String textImage = json.optString("image", "");
        if (textImage.length() > 0 && imageView != null) {
            activeImageRequest = new DownloadImageTask(imageView);
            activeImageRequest.execute(textImage);
        }
    }

    private void clearResultImage() {
        ImageView imageView = (ImageView) findViewById(R.id.imageView);
        if (imageView != null) {
            imageView.setImageDrawable(null);
        }
    }

    private void cancelActiveRequests() {
        if (activeSearchRequest != null) {
            activeSearchRequest.cancel(true);
            activeSearchRequest = null;
        }
        cancelActiveImageRequest();
    }

    private void cancelActiveImageRequest() {
        if (activeImageRequest != null) {
            activeImageRequest.cancel(true);
            activeImageRequest = null;
        }
    }

    private class DownloadImageTask extends AsyncTask<String, Void, Bitmap> {
        ImageView bmImage;

        public DownloadImageTask(ImageView bmImage) {
            this.bmImage = bmImage;
        }

        protected Bitmap doInBackground(String... urls) {
            if (urls == null || urls.length == 0 || urls[0] == null
                    || urls[0].trim().length() == 0) {
                return null;
            }

            Bitmap mIcon11 = null;
            InputStream in = null;
            HttpsURLConnection connection = null;
            try {
                URL imageUrl = httpsImageUrl(urls[0].trim());
                connection = (HttpsURLConnection) imageUrl.openConnection();
                connection.setInstanceFollowRedirects(false);
                connection.setConnectTimeout(IMAGE_DOWNLOAD_TIMEOUT_MILLIS);
                connection.setReadTimeout(IMAGE_DOWNLOAD_TIMEOUT_MILLIS);
                int responseCode = connection.getResponseCode();
                if (responseCode < 200 || responseCode >= 300) {
                    throw new IOException("Search image request failed");
                }
                in = connection.getInputStream();
                mIcon11 = BitmapFactory.decodeStream(in);
            } catch (Exception e) {
                Log.e(LOG_TAG, "Unable to download search image");
            } finally {
                if (in != null) {
                    try {
                        in.close();
                    } catch (IOException e) {
                        Log.e(LOG_TAG, "Unable to close search image stream");
                    }
                }
                if (connection != null) {
                    connection.disconnect();
                }
            }
            return mIcon11;
        }

        protected void onPostExecute(Bitmap result) {
            if (activeImageRequest != this || isFinishing() || isDestroyed()) {
                return;
            }

            activeImageRequest = null;
            if (result != null) {
                bmImage.setImageBitmap(result);
            }
        }
    }

    private static URL httpsImageUrl(String value) throws MalformedURLException {
        URL imageUrl = new URL(value);
        if (!"https".equalsIgnoreCase(imageUrl.getProtocol())) {
            throw new MalformedURLException("Search image URLs must use HTTPS");
        }

        return imageUrl;
    }

    @Override
    protected void onPause() {
        cancelActiveRequests();
        super.onPause();
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item == null) {
            Log.w(LOG_TAG, "Search options item is unavailable");
            return false;
        }

        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();


        return super.onOptionsItemSelected(item);
    }
}
