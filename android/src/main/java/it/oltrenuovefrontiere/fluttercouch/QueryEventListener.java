package it.oltrenuovefrontiere.fluttercouch;

import com.couchbase.lite.ListenerToken;
import com.couchbase.lite.Query;
import com.couchbase.lite.QueryChange;
import com.couchbase.lite.QueryChangeListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;

public class QueryEventListener implements EventChannel.StreamHandler {
    private ListenerToken mListenerToken;

    /*
     * IMPLEMENTATION OF EVENTCHANNEL.STREAMHANDLER
     */

    @Override
    public void onListen(Object args, final EventChannel.EventSink eventSink) {

        if (args instanceof JSONObject) {
            JSONObject json = (JSONObject) args;

            final String queryId;
            try {
                queryId = json.getString("query");
            } catch (JSONException e) {
                eventSink.error("errArg", "Missing Arguments", json);
                return;
            }

            Query query = CBManager.instance.getQuery(queryId);
            if (query != null) {
                mListenerToken = query.addChangeListener(new QueryChangeListener() {
                    @Override
                    public void changed(QueryChange change) {
                        HashMap<String,Object> json = new HashMap<String,Object>();
                        json.put("query",queryId);

                        if (change.getResults() != null) {
                            json.put("results",QueryJson.resultsToJson(change.getResults()));
                        }

                        if (change.getError() != null) {
                            json.put("error",change.getError().getLocalizedMessage());
                        }

                        eventSink.success(json);
                    }
                });
            }
        } else {
            eventSink.error("errArg", "Missing Arguments", args);
        }
    }

    @Override
    public void onCancel(Object args) {
        if (args instanceof JSONObject) {
            JSONObject json = (JSONObject) args;

            final String queryId;
            try {
                queryId = json.getString("query");
            } catch (JSONException e) {
                return;
            }

            Query query = CBManager.instance.getQuery(queryId);
            if (query != null && mListenerToken != null) {
                query.removeChangeListener(mListenerToken);
            }
        }

        mListenerToken = null;
    }
}
